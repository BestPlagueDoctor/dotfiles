{ config, pkgs, inputs, lib, user, root, ... }:

{
  boot = {
    initrd = {
      #includeDefaultModules = false;
      verbose = false;
      # in case i lose it
      #kernelModules = [ "nvme" "amdgpu" "vfio_pci" "vfio" "vfio_iommu_type1" "vfio_virqfd"];
      #kernelModules = [ "amdgpu" "nvme" ];
    };

    consoleLogLevel = 0;

    #kernelModules = [ "kvm-amd" "kvm-intel" "amdgpu" "vfio_pci" "vfio" "vfio_iommu_type1" "vfio_virqfd"];
    kernelModules = [ "nvme" "nvidia" ];
    #blacklistedKernelModules = [ "nvidia" "nouveau" ];
    #kernelParams = [ "amd_iommu=on" "fbcon=map:1" "video=DP-1:1024x768@60" "video=DP-2:1920x1200@60" "video=HDMI-A-1:1920x1080@144" ];
    #extraModprobeConfig = "options kvm_intel nested=1 vfio-pci ids=10de:2484, 10de:228b ";

    #postBootCommands = ''
    #  DEVS="0000:08:00.0 0000:08:00.1"
    #
    #  for DEV in $DEVS; do
    #    echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    #  done
    #  modprobe -i vfio-pci
    #'';
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
  };

  networking = {
    hostId = "c2c58d17";
    hostName = "lithium";
    wireless.iwd.enable = lib.mkForce false;
    interfaces."enp7s0".wakeOnLan.enable = true;
    firewall.allowedTCPPorts = [ 8080 ];
  };

  hardware = {
    bluetooth.enable = true;
    cpu.amd.updateMicrocode = true;
    enableAllFirmware = true;
    nvidia.open = false;

    # sunshine input
    uinput.enable = true;

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  services = {
    iperf3.enable = true;
    xserver.videoDrivers = [ "nvidia" ];

    sunshine = {
      enable = true;
      autoStart = true;
      openFirewall = true;
      # capSysAdmin = true;  # only enable if wlr-screencopy capture fails under Hyprland
    };

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.uwsm}/bin/uwsm start default";
          user = "${user.login}";
        };
      };
    };
  };

  security.tpm2.enable = lib.mkForce false;

  programs.steam.enable = true;

  users = {
    users = {
      "${user.login}" = {
        hashedPassword = "$6$uu5eUSdw0QK9hPOK$jPrHDxfbRrk5aJw9HX/TNkv5.F.vcqFQhVu3Reuw6Az83/P/bERiTWMOYoHxfXatoroIYoHcocMACir09wMtw.";
        extraGroups = [
          "adbusers"
          "i2c"
          "libvirtd"
          "lp"
          "plugdev"
          "scanner"
          "uinput"
        ];
      };
    };
  };

  home-manager = {
    backupFileExtension = "bak";
    users."${user.login}" = {
      imports = [ ../../home ];
      #xdg.configFile."Kvantum/Base16Kvantum/Base16Kvantum.svg".force = true;
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
              name = "lithium";
              output = [
                {
                  enable = true;
                  search = [ "n/DP-3" ];
                  mode = "1024x768@60";
                  #mode = "best";
                  position = {
                    x = 0;
                    y = 650;
                  };
                }
                {
                  enable = true;
                  search = ["m=DELL U2415" "s=CFV9N7623DCS" "v=Dell Inc."];
                  mode = "best";
                  transform = "90";
                  position = {
                    x = 3584;
                    y = 0;
                  };
                }
                {
                  enable = true;
                  search = ["m=G274QPF E2" "s=CC2HJ64802553" "v=Microstep"];
                  mode = "2560x1440@144.001007";
                  #mode = "best";
                  position = {
                    x = 1024;
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
      enableSocial = true;
      cursorColor = "fc03db";
      cursorSize = 48;
    };
  };

  environment = {
    defaultPackages = lib.mkForce [ ];
    systemPackages = (with pkgs; [ spotify ]);
  };

  system.stateVersion = "24.11";
}
