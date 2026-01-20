{ lib
, pkgs
, inputs
, user
, root
, config
, ...
}:

{
  home.packages = with pkgs; [ spotify ];
  programs.git.delta.options.navigate = true;
  systemd.user.services = {
    rclone-cobalt = lib.mkForce {};
    rclone-oxygen = lib.mkForce {};
  };
}

