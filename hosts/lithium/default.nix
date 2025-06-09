{ config, pkgs, inputs, lib, user, ... }:

{
  boot = {
    initrd = {
      #includeDefaultModules = false;
      verbose = false;
      # in case i lose it
      #kernelModules = [ "nvme" "amdgpu" "vfio_pci" "vfio" "vfio_iommu_type1" "vfio_virqfd"];
      kernelModules = [ "amdgpu" "nvme" ];
    };

    consoleLogLevel = 0;

    kernelModules = [ "kvm-amd" "kvm-intel" "amdgpu" "vfio_pci" "vfio" "vfio_iommu_type1" "vfio_virqfd"];
    blacklistedKernelModules = [ "nvidia" "nouveau" ];
    kernelParams = [ "amd_iommu=on" "fbcon=map:1" "video=DP-1:1024x768@60" "video=DP-2:1920x1200@60" "video=HDMI-A-1:1920x1080@144" ];
    #extraModprobeConfig = "options kvm_intel nested=1 vfio-pci ids=10de:2484, 10de:228b ";

    postBootCommands = ''
      DEVS="0000:08:00.0 0000:08:00.1"

      for DEV in $DEVS; do
        echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
      done
      modprobe -i vfio-pci
    '';
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
    interfaces."enp7s0".wakeOnLan.enable = true;
    firewall.allowedTCPPorts = [ 8080 ];
  };

  hardware = {
    enableAllFirmware = true;

    bluetooth.enable = true;
    cpu.amd.updateMicrocode = true;

    graphics = {
      extraPackages = with pkgs; [
        amdvlk
      ];
      extraPackages32 = with pkgs; [ driversi686Linux.amdvlk];
    };

    #nvidia = {
    #  package = config.boot.kernelPackages.nvidiaPackages.stable;
    #  open = true;
    #  modesetting.enable = true;
    #};
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  services = {
    iperf3.enable = true;
    xserver.videoDrivers = [ "amdgpu" ];
  };

  virtualisation = {
    spiceUSBRedirection.enable = false;

    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
      };
    };
  };

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
          "qemu-libvirtd"
        ];
      };
    };
  };

  home-manager.users."${user.login}" = {
    services.shikane = {
      enable = true;
      settings = {
        #profile = [
        #  {
        #    name = "default";
        #    output = [
        #      {
        #        enable = true;
        #        search = [ "m=XG270QG" "s=#ASN3IWn/L/jd" "v=ViewSonic Corporation" ];
        #        mode = "best";
        #        position = {
        #          x = 0;
        #          y = 525;
        #        };
        #      }
        #      {
        #        enable = true;
        #        search = [ "m=LG Ultra HD" "s=0x00028C0E" "v=LG Electronics" ];
        #        mode = "best";
        #        position = {
        #          x = 2560;
        #          y = 0;
        #        };
        #      }
        #    ];
        #  }
        #];
      };
    };
  };

  environment = {
    defaultPackages = lib.mkForce [ ];
    systemPackages = (with pkgs; [ radeontop ]);
  };
  
  system.stateVersion = "24.11";
}
