{ config, pkgs, lib, user, root, inputs, ... }:

{
  boot = {
    supportedFilesystems = [ "bcachefs" ];
    initrd.supportedFilesystems = [ "bcachefs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

# NFS mounts to expose media to Kodi
# NOTE: when I transfer this server to a real guy, I'm going to need to do all this again
  fileSystems."/" = { 
    device = "/dev/disk/by-uuid/de0a7a75-0032-4556-a7bf-3ec140644402";
    fsType = "ext4";
  };

  fileSystems."/boot" = { 
    device = "/dev/disk/by-uuid/38D6-7A92";
    fsType = "vfat";
  };

  fileSystems."/srv/tank" = {
    device = "/dev/disk/by-uuid/efaaa7ec-a9eb-4a10-9b32-33b8f04c1247";
    fsType = "bcachefs";
    options = [ "defaults" "nofail" "compression=zstd" ];
  };

  fileSystems."/export/music" = {
    device = "/srv/tank/public/music";
    options = [ "bind" ];
  };

  fileSystems."/export/tv" = {
    device = "/srv/tank/public/tv";
    options = [ "bind" ];
  };

  fileSystems."/export/movies" = {
    device = "/srv/tank/public/movies";
    options = [ "bind" ];
  };

  fileSystems."/export/games" = {
    device = "/srv/tank/public/games";
    options = [ "bind" ];
  };

  nix = {
    settings = {
      trusted-users = [ "@wheel" ];
      allowed-users = [ "@users" "@wheel" ];
      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "flakes"
        "nix-command"
        "recursive-nix"
      ];
      warn-dirty = false;
    };
  };

    
  nixpkgs.hostPlatform = "x86_64-linux";

  networking = {
    hostName = "magi";

    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    interfaces.enp6s0 = {
      useDHCP = true;
      wakeOnLan.enable = true;
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 111 2049 4000 4001 4002 20048 ];
      allowedUDPPorts = [ 111 2049 4000 4001 4002 20048];
    };
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    keyMap = "us";
    font = "Tamsyn7x13r";
    packages = [ pkgs.tamsyn ];
    earlySetup = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;

    groups.dufs = {};

    users = {
      root = {
        home = lib.mkForce "/home/root";
      };

      "${user.login}" = {
        isNormalUser = true;
        extraGroups = [ "dufs" "wheel" ];
      };

      dufs = {
        isSystemUser = true;
        group = "dufs";
      };
    };
  };

  environment = {
    defaultPackages = lib.mkForce [ ];
    systemPackages = with pkgs; [
      bottom
      btop
      comma
      doas-sudo-shim
      fd
      git
      hdparm
      ldns
      lm_sensors
      lshw
      nmap
      pciutils
      profanity
      ripgrep
      rsync
      tmux
      tree
      usbutils
      wget
      figlet
      wakeonlan
      rxvt-unicode
    ];

    shellAliases = {
      sudo = "doas";
    };
  };

  programs = {
    mosh.enable = true;
    mtr.enable = true;
    zsh.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      configure = {
        customRC = ''
          set number
          set hidden
          set shell=bash
          set cmdheight=2
          set nocompatible
          set shortmess+=c
          set updatetime=300
          set background=dark
          set foldmethod=marker
          set signcolumn=yes
          set nobackup nowritebackup
          set tabstop=2 shiftwidth=2 expandtab
          set tagrelative
          set tags^=./.git/tags;
        set mouse=a
          '';
      };
    };
  };

  services = {
    fstrim.enable = true;
    haveged.enable = true;
    smartd.enable = true;
    timesyncd.enable = true;
    udisks2.enable = true;
    fail2ban.enable = false;

    minecraft-server = {
      enable = false;
      eula = true;
    };

    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    nfs = {
      server.enable = true;
      server.lockdPort = 4001;
      server.mountdPort = 4002;
      server.statdPort = 4000;
      server.exports = ''
      /export 10.0.0.86(rw,all_squash,insecure,anonuid=1000,anongid=100)
      /export/music 10.0.0.86(rw,all_squash,insecure,anonuid=1000,anongid=100)
      /export/movies 10.0.0.86(rw,all_squash,insecure,anonuid=1000,anongid=100)
      /export/tv 10.0.0.86(rw,all_squash,insecure,anonuid=1000,anongid=100)
      /export/games 10.0.0.86(rw,all_squash,insecure,anonuid=1000,anongid=100)
    '';
    };

    nginx = {
      user = "sam";
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."plague.oreo.ooo" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://[::1]:8001";
        extraConfig = ''
          ignore_invalid_headers off;
          client_max_body_size 0;
          proxy_buffering off;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_connect_timeout 300;
          proxy_http_version 1.1;
          proxy_set_header Connection "";
          chunked_transfer_encoding off;
        '';
      };
    };
  };

  systemd = {
    watchdog.rebootTime = "15s";

    tmpfiles.rules = [
      "d /run/cache 0755 - - -"
      "d /var/etc 0755 - - -"
      "d /var/srv 0755 - - -"
      "d /run/tmp 1777 - - -"

      "L /srv - - - - /var/srv"
    ];

    services = {
      magi-dufs = {
        description = "magi DUFS";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Type = "exec";
          User = "dufs";
          ExecStart = ''
            ${pkgs.dufs}/bin/dufs -c /etc/dufs.yaml
          '';
        };
      };
    };
  };

  home-manager = {
    users."${user.login}" = import "${root}/home";
    extraSpecialArgs = {
      inherit inputs root user;
      stateVersion = config.system.stateVersion;
     isHeadless = true;
    };
  };

  security = {
    auditd.enable = true;
    sudo.enable = false;
    pam.services.sshd.showMotd = true;

    allowUserNamespaces = true;
    protectKernelImage = true;
    unprivilegedUsernsClone = false;

    acme = {
      acceptTerms = true;
      defaults.email = user.email;
    };

    doas = {
      enable = true;
      extraRules = [{
        groups = [ "wheel" ];
        keepEnv = true;
        noPass = false;
      }];
    };
  };

  system.stateVersion = lib.mkForce "24.11";
}
