{ config, pkgs, inputs, lib, user, ... }:

{
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ tp_smapi ];
    initrd.availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];

    kernelModules = [ "kvm-intel" "tp_smapi" ];
    kernelParams = [ "i915.enable_rc6=7" ];
  };

  # TODO find and update
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a0ee1bf5-0636-4472-b8d7-b741a5528c36";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/FA54-EACA";
      fsType = "vfat";
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  networking = {
    hostName = "navi";
    interfaces.enp0s25.useDHCP = true;
    firewall.allowedTCPPorts = [8080];
  };

  security.tpm2.enable = lib.mkForce false;

  services = {
    logind.lidSwitch = lib.mkForce "ignore";
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = true;

    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
          libvdpau-va-gl
          vaapiIntel
          vaapiVdpau
      ];
    };

    trackpoint = {
      enable = true;
      sensitivity = 150;
      speed = 97;
      emulateWheel = true;
    };
  };

  users.users."${user.login}" = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$KQUPupwm7OM42J3ahuBef/$gmB07g1pFP2SPgXZTJHpHK9AAnAyJZRlZmT5UqcyaW4";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "adbusers" ];
  };

  home-manager.users."${user.login}" = {
    imports = [ ../../home ];
  };

  environment = {
    defaultPackages = lib.mkForce [ ];
  };

  zramSwap.enable = true;
  system.stateVersion = lib.mkForce "24.11";
}

