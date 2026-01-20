{ config, pkgs, inputs, lib, user, ... }:

{
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ ];

    kernel.sysctl."net.ipv4.ip_forward" = true; # gitlab runner
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  networking = {
    hostName = "motherbrain";
    interfaces.eno1.useDHCP = true;
    firewall.allowedTCPPorts = [ 22 47984 47989 47990 48010 ];
    firewall.allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
      { from = 8000; to = 8010; }
    ];
  };

  security.tpm2.enable = lib.mkForce false;

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = true;

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        libvdpau-va-gl
        intel-vaapi-driver
        libva-vdpau-driver
      ];
    };
  };

  users.users."${user.login}" = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$JfktHdKsErtyUlTOQVwdS/$9lm./UIqSOPqbW9g3Y/YO6/0WFxlazDxLUL5SeuCMZ2";
    shell = pkgs.zsh;
    extraGroups = [ "docker" "wheel" "networkmanager" ];
  };

  home-manager = {
    users."${user.login}" = {
      imports = [ ../../home ];
      xdg.mime.enable = true;
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "x-scheme-handler/http" = ["firefox.desktop"];
          "x-scheme-handler/https" = ["firefox.desktop"];
          "x-scheme-handler/pdf" = ["firefox.desktop"];
          "inode/directory" = ["dolphin.desktop"];
        };
      }; 

      services.shikane = {
        enable = true;
        settings = {
          profile = [
            {
              name = "motherbrain";
              output = [
                {
                  enable = true;
                  search = ["n/HDMI-A-2"];
                  mode = "1920x1080@75.001999";
                  #mode = "best";
                  position = {
                    x = 1080;
                    y = 300;
                  };
                }
                {
                  enable = true;
                  search = ["n/VGA-1"];
                  mode = "1920x1080@60.000000";
                  #mode = "best";
                  position = {
                    x = 3000;
                    y = 250;
                  };
                }
                {
                  enable = true;
                  search = ["m=DELL P2317H" "s=CG1G378S130B" "v=Dell Inc."];
                  mode = "best";
                  transform = "90";
                  position = {
                    x = 0;
                    y = 0;
                  };
                }
              ];
            }
          ];
        };
      };
    };
    extraSpecialArgs = {
      enableSocial = false;
      cursorColor = "fc03db";
      cursorSize = 4;
    };
  };

  virtualisation = {
    docker.enable = true; # gitlab runner
    podman = {
      enable = true;
      dockerCompat = lib.mkForce false;
    };
  };

  services = {
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    gitlab-runner = {
      enable = true;
      configFile = "/etc/gitlab-runner-config.toml";
    };
  };



  environment = {
    defaultPackages = lib.mkForce [ ];
    systemPackages = with pkgs; [
      teams-for-linux 
      distrobox 
      bcompare
    ];

    etc."distrobox/distrobox.conf".text = ''
      container_additional_volumes="/etc/profiles:/etc/profiles:ro /etc/static:/etc/static:ro"
      PATH="/usr/bin:/bin:$PATH"
      NAME="devbox"
    '';
    
    etc."gitlab-runner-config.toml".text = ''
      concurrent = 1
      check_interval = 0

      [[runners]]
        name = "test runner"
        url = "https://git.ami.com"
        token = "***REMOVED***"
        executor = "docker"
        output_limit = 40000000

        [runners.docker]
          image = "ubuntu_oks:latest"

    '';
  };

  zramSwap.enable = true;
  system.stateVersion = lib.mkForce "24.11";
}

