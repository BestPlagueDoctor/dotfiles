{ config, pkgs, lib, root, user, isHeadless, ... }:

{
  services = {  
    #mpd-mpris.enable = true;
    #mpris-proxy.enable = true;
    playerctld.enable = true;

    emacs = {
      enable = false;
      # TODO: Fix upstream.
      defaultEditor = false;

      client = {
        enable = true;
        arguments = [ "-n" "-t" "-c" ];
      };
    };

    hypridle = {
      enable = !isHeadless;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "pgrep hyprlock || hyprlock";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    mpd = {
      enable = false;
      network.startWhenNeeded = true;
      extraConfig = ''
      audio_output {
        type "pipewire"
        name "Pipewire Playback"
      }
    '';
    };

    wlsunset = {
        enable = !isHeadless;
        latitude = 33.7;
        longitude = -84.3;
    };
  };
}

