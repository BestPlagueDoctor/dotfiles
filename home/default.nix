{ lib
, pkgs
, inputs
, user
, root
, config
, ...
}:

let
  home = config.home.homeDirectory;
in

{
  home.packages = with pkgs; [ spotify ];
  programs.git.delta.options.navigate = true;
  systemd.user.services = {
    rclone-cobalt = lib.mkForce {};
    rclone-oxygen = lib.mkForce {};
  };
  wayland.windowManager.hyprland.settings.dwindle.pseudotile = lib.mkForce false;
}

