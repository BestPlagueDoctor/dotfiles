{ config, pkgs, lib, user, root, inputs, ... }:

let
  # Wrapper script that injects NVIDIA/Wayland env vars before starting sway.
  # greetd starts this directly as the kodi user, so it owns the full session.
  #export GBM_BACKEND=nvidia-drm
  swayKodi = pkgs.writeShellScript "sway-kodi" ''
    export LIBVA_DRIVER_NAME=iHD
    export MOZ_ENABLE_WAYLAND=1
    export WLR_NO_HARDWARE_CURSORS=1
    export WLR_DRM_DEVICES=/dev/dri/card1
    exec ${pkgs.sway}/bin/sway "$@"
  '';
in
{
  boot = {
    #kernelPackages = pkgs.linuxPackages_6_12;
    #extraModulePackages = [ config.boot.kernelPackages.rtl88x2bu ];
    #kernelModules = [ "i915" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
    kernelModules = [ "i915" ];
    kernelParams = [ "nvidia-drm.modeset=1" ];
    blacklistedKernelModules = [ "nouveau" ];
    kernel.sysctl."net.ipv4.ip_forward" = lib.mkForce 1;
    supportedFilesystems = [ "bcachefs" ];
    initrd.supportedFilesystems = [ "bcachefs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

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

  # make sure it's using the right driver
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics.enable = true;
    #graphics.extraPackages = with pkgs; [   intel-media-driver libva-vdpau-driver nvidia-vaapi-driver ];
    graphics.extraPackages = with pkgs; [ intel-media-driver ];
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  nixpkgs.config.cudaSupport = true;

  networking = {
    networkmanager.enable = lib.mkForce false;
    hostName = "magi";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    interfaces.enp9s0f0 = {
      useDHCP = true;
      wakeOnLan.enable = true;
    };
    wireless.iwd.enable = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 3000 8080 8096 8920 44455 ];
      allowedUDPPorts = [ 44455 51820 ];
    };
    wireguard.interfaces = {
      magi-remote = {
        ips = [ "10.100.0.1/24" ];
        listenPort = 51820;
        privateKeyFile = config.age.secrets.magi-remote-incoming.path;
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o enp9s0f0 -j MASQUERADE
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o enp9s0f0 -j MASQUERADE
        '';
        peers = [
          {
            publicKey = "33yQdOCzm7Cq5jE9DwF1grXIj5NTiqhj5rloeXiV4hU=";
            allowedIPs = [ "10.100.0.2/32" ];
          }
        ];
      };
    };
  };

  time.timeZone = lib.mkForce "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    keyMap = "us";
    font = "Tamsyn7x13r";
    packages = [ pkgs.tamsyn ];
  };

  users = {
    defaultUserShell = pkgs.zsh;
    groups.dufs = { };
    users = {
      root = {
        home = lib.mkForce "/home/root";
      };
      "${user.login}" = {
        hashedPassword = "$y$j9T$Rv6bcZbZ6Xp5LScQygp.Q.$N8wB0xhT2IKj9ozkg8PvGG04cETWLuIQN/2.QEht.tD";
        isNormalUser = true;
        extraGroups = [ "pulse-access" "audio" "video" "minecraft" "dufs" "wheel" ];
      };
      dufs = {
        isSystemUser = true;
        group = "dufs";
      };
      kodi.isNormalUser = true;
      # Added "seat" — greetd + sway use logind for seat management, this covers
      # edge cases where direct DRM access is needed.
      kodi.extraGroups = [ "pulse-access" "audio" "video" "input" "render" "seat" ];
      immich.extraGroups = [ "video" "render" ];
      jellyfin.extraGroups = [ "video" "render" ];
    };
  };

  environment = {
    defaultPackages = lib.mkForce [ ];
    systemPackages = with pkgs; [
      bottom
      btop
      comma
      doas-sudo-shim
      egl-wayland
      fd
      figlet
      git
      hdparm
      ldns
      lm_sensors
      lshw
      moonlight-qt
      moonlight-embedded
      nmap
      pciutils
      profanity
      ripgrep
      rsync
      rxvt-unicode
      tmux
      tree
      usbutils
      wakeonlan
      wget
    ];

    shellAliases = {
      sudo = "doas";
    };

    # Only keep what's relevant for interactive SSH sessions.
    # The Wayland/NVIDIA vars now live in swayKodi and reach the compositor
    # directly via greetd — no more env pollution for headless services.
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    # Launcher script at a stable /etc path. favourites.xml references this
    # path directly, so it never needs updating when moonlight's store hash
    # changes. The binary path inside the script DOES update on rebuild.
    etc."kodi/moonlight-launcher.py" = {
      mode = "0444";
      # Use the stable NixOS symlink rather than a store path — store paths can
      # go missing if the package hasn't been built yet or was GC'd between
      # evals. /run/current-system/sw/bin is always current after activation.
      text = ''
        import subprocess
        subprocess.Popen(['/run/current-system/sw/bin/moonlight'])
      '';
    };

    # System-wide sway config — kodi user has no ~/.config/sway/config so
    # sway falls back to this. Kodi launches fullscreen on start; moonlight-qt
    # is a proper first-class Wayland window bound to Super+m.
    etc."sway/config".text = ''
      output * bg #000000 solid_color
      seat * hide_cursor 3000

      bar {
        mode invisible
      }

      exec ${pkgs.kodi-wayland}/bin/kodi --windowing=wayland

      bindsym Mod4+m exec ${pkgs.moonlight-qt}/bin/moonlight

      for_window [app_id="kodi"] fullscreen enable
      for_window [title="Moonlight"] fullscreen enable
      for_window [app_id="com.moonlight-stream.Moonlight"] fullscreen enable

      # Emergency exit — Super+Shift+e kills the sway session (greetd restarts it)
      bindsym Mod4+Shift+e exec swaymsg exit
    '';
  };

  programs = {
    mosh.enable = true;
    mtr.enable = true;
    zsh.enable = true;

    sway = {
      enable = true;
      wrapperFeatures.gtk = true; # Required for GTK apps to work properly
    };

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
    fail2ban.enable = false;
    fstrim.enable = true;
    haveged.enable = true;
    pulseaudio.enable = true;
    pulseaudio.systemWide = true;
    pipewire.enable = lib.mkForce false;
    smartd.enable = true;
    timesyncd.enable = true;
    udisks2.enable = true;

    # greetd replaces cage. initial_session autologs in as kodi and starts sway
    # via the swayKodi wrapper (which sets all NVIDIA env vars). If sway exits,
    # default_session brings it right back up.
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = toString swayKodi;
          user = "kodi";
        };
        initial_session = {
          command = toString swayKodi;
          user = "kodi";
        };
      };
    };

    cloudflare-dyndns = {
      enable = true;
      domains = [ "plague.oreo.ooo" ];
      apiTokenFile = config.age.secrets.cloudflare-api-token.path;
    };

    immich = {
      enable = true;
      port = 3000;
      mediaLocation = "/srv/tank/photos";
      host = "0.0.0.0";
      openFirewall = true;
      accelerationDevices = [ "cuda0" ]; # Use "renderD128" if you are using Intel/AMD
      machine-learning = {
        enable = true;
        environment = {
          IMMICH_MACHINE_LEARNING_PROVIDER = "cuda"; # Use "openvino" for Intel
          LD_LIBRARY_PATH = "${pkgs.python312Packages.onnxruntime}/lib/python3.12/site-packages/onnxruntime/capi";
        };
      };
    };

    transmission = {
      enable = true;
      package = pkgs.transmission_4;
      openFirewall = false;
      openRPCPort = true;
      settings = {
        "rpc-bind-address" = "192.168.15.1";
        "rpc-whitelist" = "*";
      };
    };

    minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      declarative = true;
      serverProperties = {
        server-port = 44455;
        enable-rcon = true;
        "rcon.port" = 44456;
        "rcon.password" = "letmein!";
        difficulty = 3;
        gamemode = 0;
        max-players = 10;
        motd = "we are so back";
        allow-cheats = true;
        view-distance = 16;
        simulation-distance = 16;
      };
      jvmOpts = "-Xmx8G -Xms8G -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysActAsServerClassMachine -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseNUMA -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:ThreadPriorityPolicy=1 -XX:AllocatePrefetchStyle=3 -XX:+UseG1GC -XX:MaxGCPauseMillis=130 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=28 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=20 -XX:G1MixedGCCountTarget=3 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=0 -XX:SurvivorRatio=32 -XX:MaxTenuringThreshold=1 -XX:G1SATBBufferEnqueueingThresholdPercent=30 -XX:G1ConcMarkStepDurationMillis=5 -XX:G1ConcRSHotCardLimit=16 -XX:G1ConcRefinementServiceIntervalMillis=150 -XX:ConcGCThreads=2";
    };

    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    jellyfin = {
      enable = true;
      hardwareAcceleration = {
        enable = true;
        type = "nvenc";
        device = "/dev/dri/by-path/pci-0000:01:00.0-render";
      };
    };

    nginx = {
      user = "sam";
      enable = true;
      enableReload = true;
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

      virtualHosts."foto.oreo.ooo" = {
        enableACME = true;
        forceSSL = true;
        locations =
          let
            proxyPass = "http://127.0.0.1:3000";
            commonProxy = ''
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Protocol $scheme;
              proxy_set_header X-Forwarded-Host $http_host;
            '';
          in
          {
            "/" = {
              inherit proxyPass;
              extraConfig = commonProxy + ''
                proxy_buffering off;
              '';
            };
            "/socket" = {
              inherit proxyPass;
              proxyWebsockets = true;
              extraConfig = commonProxy;
            };
          };
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };

      virtualHosts."ooo.oreo.ooo" = {
        enableACME = true;
        forceSSL = true;
        locations =
          let
            proxyPass = "http://127.0.0.1:8096";
            commonProxy = ''
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header X-Forwarded-Protocol $scheme;
              proxy_set_header X-Forwarded-Host $http_host;
            '';
          in
          {
            "/" = {
              inherit proxyPass;
              extraConfig = commonProxy + ''
                proxy_buffering off;
              '';
            };
            "/socket" = {
              inherit proxyPass;
              proxyWebsockets = true;
              extraConfig = commonProxy;
            };
          };
        extraConfig = ''
          client_max_body_size 20M;
          add_header X-Frame-Options "SAMEORIGIN";
          add_header X-Content-Type-Options "nosniff";
          add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), bluetooth=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), keyboard-map=(), local-fonts=(), magnetometer=(), microphone=(), payment=(), publickey-credentials-get=(), serial=(), sync-xhr=(), usb=(), xr-spatial-tracking=()" always;
          add_header Content-Security-Policy "default-src https: data: blob: ; img-src 'self' https://* ; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; frame-ancestors 'self'";
        '';
      };
    };
  };

  # Seed favourites.xml on first boot only — Kodi can add more entries via the
  # UI and they'll persist across rebuilds. The launcher path is stable (/etc)
  # so this file never needs to change after the initial write.
  system.activationScripts.kodi-userdata = {
    text = ''
      USERDATA=/home/kodi/.kodi/userdata
      FAVFILE=$USERDATA/favourites.xml
      if [ ! -f "$FAVFILE" ]; then
        mkdir -p "$USERDATA"
        cat > "$FAVFILE" <<'EOF'
<favourites>
  <favourite name="Moonlight" thumb="DefaultProgram.png">RunScript(/etc/kodi/moonlight-launcher.py)</favourite>
</favourites>
EOF
        chown -R kodi:kodi /home/kodi/.kodi
        chmod 644 "$FAVFILE"
      fi
    '';
  };

  systemd = {
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
            ${pkgs.dufs}/bin/dufs -c ${config.age.secrets.dufs.path}
          '';
        };
      };
    };
  };

  # vpn containment
  vpnNamespaces.igor = {
    enable = true;
    wireguardConfigFile = config.age.secrets."igor.conf".path;
    accessibleFrom = [ "192.168.1.0/24" ];
    portMappings = [{ from = 9091; to = 9091; }];
    openVPNPorts = [{ port = 27070; protocol = "both"; }];
  };

  systemd.services.transmission.vpnConfinement = {
    enable = true;
    vpnNamespace = "igor";
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
    rtkit.enable = true;
    allowUserNamespaces = true;
    protectKernelImage = true;
    #unprivilegedUsernsClone = false;
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
    tpm2.enable = lib.mkForce false;
  };

  age = {
    identityPaths = [ "/home/sam/.ssh/id_ed25519" ];
    secrets = {
      cloudflare-api-token.file = "${root}/secrets/cloudflare-api-token.age";
      magi-remote-incoming.file = "${root}/secrets/magi-remote-incoming.age";
      "igor.conf".file = "${root}/secrets/igor.age";
      dufs = {
        file = "${root}/secrets/dufs.age";
        owner = "dufs";
        group = "dufs";
      };
    };
  };

  system.stateVersion = lib.mkForce "24.11";
}

