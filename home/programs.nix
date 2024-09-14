args@{ config, osConfig, pkgs, lib, inputs, root, user, ... }:

let
  inherit (osConfig.nixpkgs) hostPlatform;
in {
  programs = {
    aria2.enable = true;
    dircolors.enable = true;
    fzf.enable = true;
    home-manager.enable = true;
    nix-index.enable = true;
    noti.enable = true;
    zathura.enable = true;
    zoxide.enable = true;

    atuin = {
      enable = true;
    
      settings = {
        style = "compact";
        enter_accept = true;
        inline_height = 30;
        show_preview = true;
        auto_sync = false;
        update_check = false;
        invert = false;
        workspaces = true;
        filter_mode_shell_up_key_binding = "session";
      };
    };

    bash = {
      enable = true;
      historyFile = "${config.xdg.cacheHome}/bash/history";
    };

    bat = {
      enable = true;
      config = {
        theme = "ayu";
      };
      themes = {
        ayu = builtins.readFile (pkgs.fetchFromGitHub
          {
            owner = "dempfi";
            repo = "ayu";
            rev = "4.0.3";
            hash = "sha256-O0zoKAmCgSAHv2gcORYrorIlw0kdXN1+2k2Emtntc2g=";
          } + "/ayu-dark.tmTheme");
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    emacs = {
      enable = true;
      package = pkgs.emacsWithPackagesFromUsePackage {
        config = "${root}/conf/emacs/init.el";
        defaultInitFile = true;
        alwaysEnsure = true;
        package = pkgs.emacs-pgtk;
      };
    };

    eza = {
      enable = true;
      git = true;
    };

    foot = {
      enable = true;
      server.enable = true;

      settings = {
        main = {
          term = "xterm-256color";
          font = "Fira Code:size=12";
          dpi-aware = "no";
        };

        mouse = {
          hide-when-typing = "yes";
        };

        colors = {
          # Ayu dark theme.
          background = "000919";
          foreground = "c3c0bb";

          regular0 = "242936"; # black
          regular1 = "f28779"; # red
          regular2 = "d5ff80"; # green
          regular3 = "ffd173"; # yellow
          regular4 = "73d0ff"; # blue
          regular5 = "dfbfff"; # magenta
          regular6 = "5ccfe6"; # cyan
          regular7 = "cccac2"; # white

          bright0 = "fcfcfc"; # bright black
          bright1 = "f07171"; # bright red
          bright2 = "86b300"; # bright gree
          bright3 = "f2ae49"; # bright yellow
          bright4 = "399ee6"; # bright blue
          bright5 = "a37acc"; # bright magenta
          bright6 = "55b4d4"; # bright cyan
          bright7 = "5c6166"; # bright white
        };
      };
    };

    git = {
      enable = true;
      userEmail = user.email;
      userName = user.name;

      aliases = {
        a = "add";
        aa = "add -A";
        br = "branch";
        ci = "commit";
        co = "checkout";
        d = "diff";
        ds = "diff --staged";
        f = "fuzzy";
        pl = "pull";
        ps = "push";
        psf = "push --force-with-lease";
        st = "status";
        sw = "switch";
        wt = "worktree";
      };

      delta = {
        enable = true;
        options = {
          syntax-theme = "ayu";
          line-numbers = true;
        };
      };

      extraConfig = {
        init.defaultBranch = "master";
        credential.helper = "store";
        core.editor = ''${config.home.sessionVariables.EDITOR}'';
        push.autoSetupRemote = true;
      };
    };

    hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 3;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 5;
            blur_size = 8;
          }
        ];

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            placeholder_text = ''<span foreground="##cad3f5">Password...</span>'';
            shadow_passes = 2;
          }
        ];
      };
    };

    mpv = {
      enable = true;
      config = {
        gpu-api = "vulkan";
        gpu-context = "wayland";
        hwdec = "vaapi";
        profile = "gpu-hq";
        spirv-compiler = "shaderc";
      };
    };

    ncmpcpp = {
      enable = true;
      bindings = [
        { key = "j"; command = "scroll_down"; }
        { key = "k"; command = "scroll_up"; }
        { key = "J"; command = [ "select_item" "scroll_down" ]; }
        { key = "K"; command = [ "select_item" "scroll_up" ]; }
      ];
    };

    nushell = {
      enable = true;
    
      shellAliases = config.home.shellAliases;
    
      envFile.text = ''
        $env.PROMPT_INDICATOR_VI_INSERT = ""
        $env.PROMPT_INDICATOR_VI_NORMAL = ""
    
        $env.config = {
          show_banner: false,
          keybindings: [],
          edit_mode: vi,
          cursor_shape: {
            emacs: line,
            vi_insert: line,
            vi_normal: underscore,
          }
        }
      '';
    };

    readline = {
      enable = true;
      extraConfig = ''
        set editing-mode vi
      '';
    };

    waybar = {
      enable = true;
      systemd.enable = true;

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 24;

          modules-left = [
            "hyprland/workspaces"
            "custom/spotify"
          ];

          modules-center = [ "hyprland/window" ];

          modules-right = [
            "pulseaudio"
            "custom/separator"
            "network"
            "custom/separator"
            "temperature"
            "custom/separator"
            "cpu"
            "custom/separator"
            "memory"
            "custom/separator"
            "battery"
            "custom/separator"
            "tray"
            "clock"
          ];

          "custom/separator" = { format = " | "; interval = "once"; tooltip = false; };

          "wlr/workspaces" = {
            disable-scroll = true;
            all-outputs = false;
            on-click = "activate";
          };

          "wlr/mode" = { format = "<span style=\"italic\">{}</span>"; };
          "tray" = {
            # "icon-size" = 21,
            "spacing" = 10;
          };

          "clock" = { "format-alt" = "{:%Y-%m-%d}"; "on-click" = ""; };
          "cpu" = {
            "format" = "{usage}% 󰍛";
          };

          "memory" = { "format"= "{}% 󰧑"; };

          "temperature" = {
            "critical-threshold" = 80;
            "format" = "{}℃  󰏈";
            "format-critical" = "{}℃ 󰇺";
            "interval" = 5;
          };

          "battery" = {
              "bat"= "BAT1";
              "states"= {
                  # "good"= 95;
                  "warning"= 30;
                  "critical"= 15;
              };
              "format"= "{capacity}% {icon}";
              # "format-good"= ""; # An empty format will hide the module
              # "format-full"= "";
              "format-charging"= "{capacity}% 󰂄";
              "format-plugged"= "{capacity}% 󰚥";
              "format-icons"= ["󰁺" "󰁼" "󰁾" "󰂀" "󰁹"];
          };

          "network" = {
              "format-wifi"= "{essid} ({signalStrength}%) 󰖩";
              "format-ethernet"= "{ifname}= {ipaddr}/{cidr} 󰈀";
              "format-disconnected"= "Disconnected ⚠";
          };

          "pulseaudio" = {
              "scroll-step"= 1;
              "format"= "{volume}% {icon}";
              "format-bluetooth"= "{volume}%{icon}󰂯";
              "format-muted"= "󰖁";
              "format-icons"= {
                  "headphones" = "󰋋";
                  "headset" = "󰋎";
                  "phone" = "󰏲";
                  "car" = "󰄋";
                  "default" = [ "󰖀" "󰕾" ];
              };
              "on-click"= "pavucontrol";
          };

          "hyprland/window" = {
            "format" = {};
            "seperate-outputs" = true;
            "rewrite" = {
              "((\\S*\\s){0,3})(.*) — Mozilla Firefox"= "ff - $1";
              "((\\S*\\s){0,3})(.*)"= "$1 ";
            };
          };
          "custom/spotify"= {
              "format"= "󰓇 {}";
              "max-length"= 40;
              "interval"= 10; # Remove this if your script is endless and write in loop
              "exec"= "$HOME/.config/waybar/mediaplayer.sh 2> /dev/null"; # Script in resources folder
              "exec-if"= "pgrep spotify || pgrep ncspot";
          };
          "custom/weather" = {
            "format" = "{}";
            "exec" = "curl -s wttr.in/\?format=\"Urbana:+%C,+%t+%w\"";
            "interval" = 1800;
          };
        };
      };
    };

    yazi = {
      enable = true;
    };
    
    yt-dlp = {
      enable = true;
      settings = {
        embed-thumbnail = true;
        downloader = "aria2c";
        downloader-args = "aria2c:'-c -x8 -s8 -k1M'";
      };
    };


    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = false;

      autocd = true;
      defaultKeymap = "viins";

      dotDir = "${builtins.baseNameOf config.xdg.configHome}/zsh";

      history = {
        path = "${config.xdg.cacheHome}/zsh/history";
        ignoreSpace = true;
      };

      initExtraFirst = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
        [[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
        function zshaddhistory() { return 1 }

        bindkey '^ ' autosuggest-accept
        _zsh_autosuggest_strategy_atuin_top() {
            suggestion=$(atuin search --cmd-only --limit 1 --search-mode prefix $1)
        }

        ZSH_AUTOSUGGEST_STRATEGY=atuin_top
     '';

     initExtraBeforeCompInit = ''
       autoload -Uz zcalc
       autoload -Uz edit-command-line

       zle-keymap-select () {
         if [ $KEYMAP = vicmd ]; then
           printf "\033[2 q"
         else
           printf "\033[6 q"
         fi
       }

       zle -N zle-keymap-select

       zle-line-init () {
         zle -K viins
         printf "\033[6 q"
       }

       zle -N zle-line-init


        zle -N edit-command-line
        bindkey -M vicmd v edit-command-line
        bindkey -v '^?' backward-delete-char

        setopt globdots
        setopt autopushd
      '';
    };
  };
}
