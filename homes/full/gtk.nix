{ config, pkgs, ... }:

{
  enable = true;

  cursorTheme = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ-AA";
    size = 16;
  };
}
