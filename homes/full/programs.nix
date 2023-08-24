{ config, pkgs, lib, root, user, ... }:

{
  aria2.enable = true;
  dircolors.enable = true;
  fzf.enable = true;
  home-manager.enable = true;
  nix-index.enable = true;
  noti.enable = true;
  zathura.enable = true;
  zoxide.enable = true;

  bash = {
    enable = true;
    historyFile = "${config.xdg.cacheHome}/bash/history";
  };

  bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
    themes = {
      dracula = builtins.readFile (pkgs.fetchFromGitHub
        {
          owner = "dracula";
          repo = "sublime";
          rev = "26c57ec282abcaa76e57e055f38432bd827ac34e";
          sha256 = "019hfl4zbn4vm4154hh3bwk6hm7bdxbr1hdww83nabxwjn99ndhv";
        } + "/Dracula.tmTheme");
    };
  };

  broot = {
    enable = true;
    settings = {
      modal = true;
    };
  };

  direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

 emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;

    init = {
      enable = true;
      packageQuickstart = false;
      recommendedGcSettings = true;
      usePackageVerbose = false;

      earlyInit = ''
        (auto-compression-mode 1)
        (push '(menu-bar-lines . 0) default-frame-alist)
        (push '(tool-bar-lines . nil) default-frame-alist)
        (push '(vertical-scroll-bars . nil) default-frame-alist)

        (setq frame-title-format "")

        (set-face-attribute 'default nil
                            :family "Tamsyn"
                            :height 120
                            :weight 'normal
                            :width 'normal)
      '';

      prelude = ''
        (setq gc-cons-threshold most-positive-fixnum)

        (let ((path (shell-command-to-string ". ~/.zshenv; . ~/.profile; echo -n $PATH")))
          (setenv "PATH" path)
          (setq exec-path
                (append
                 (split-string-and-unquote path ":")
                 exec-path)))

        (defvar --backup-directory "~/.cache/emacs/backups")
        (if (not (file-exists-p --backup-directory))
            (make-directory --backup-directory t))
        (setq backup-directory-alist `(("." . ,--backup-directory)))
        (setq make-backup-files t
              backup-by-copying t
              version-control t
              delete-old-versions t
              delete-by-moving-to-trash t
              kept-old-versions 6
              kept-new-versions 9
              auto-save-default t
              auto-save-timeout 20
              auto-save-interval 200)

        (setq visual-bell 1)

        (setq save-place-mode t)

        (setq inhibit-startup-screen t
              inhibit-startup-echo-area-message (user-login-name))

        (setq initial-major-mode 'fundamental-mode
              initial-scratch-message nil)

        (setq blink-cursor-mode nil)

        (setq custom-safe-themes t)

        (set-face-background 'mouse "#ffffff")

        (defalias 'yes-or-no-p 'y-or-n-p)

        (setq read-process-output-max (* 1024 1024))

        (line-number-mode)
        (column-number-mode)
        (setq display-line-numbers-type 'relative)
        (global-display-line-numbers-mode)

        (put 'narrow-to-region 'disabled nil)
        (put 'upcase-region 'disabled nil)
        (put 'downcase-region 'disabled nil)

        (setq
         js-indent-level 2
         c-default-style "k&r"
         c-basic-offset 2
         verilog-indent-level 2
         verilog-indent-level-declaration 2
         verilog-indent-level-directive 2
         verilog-indent-level-behavioral 2
         verilog-indent-level-module 2
         verilog-auto-newline nil
         verilog-indent-lists nil)

        (setq-default indent-tabs-mode nil
                      tab-width 2
                      c-basic-offset 2)

        (set-default 'semantic-case-fold t)

        (setq-default show-trailing-whitespace t)
        (dolist (hook '(special-mode-hook
                        term-mode-hook
                        comint-mode-hook
                        compilation-mode-hook
                        minibuffer-setup-hook))
          (add-hook hook
            (lambda () (setq show-trailing-whitespace nil))))

        (defun crm-indicator (args)
          (cons (format "[CRM%s] %s"
                        (replace-regexp-in-string
                         "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                         crm-separator)
                        (car args))
                (cdr args)))
        (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

        (setq completion-cycle-threshold 3
              tab-always-indent 'complete)

        ;; Do not allow the cursor in the minibuffer prompt.
        (setq minibuffer-prompt-properties
              '(read-only t cursor-intangible t face minibuffer-prompt))
        (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

        ;; Hide commands in M-x which do not work in the current mode.
        ;; Vertico commands are hidden in normal buffers.
        (setq read-extended-command-predicate
              #'command-completion-default-include-p)

        (setq enable-recursive-minibuffers t)

        (setq sentence-end-double-space nil)

        (prefer-coding-system 'utf-8)

        (transient-mark-mode 1)

        (setq scroll-step 1
              scroll-margin 7
              scroll-conservatively 100000)

        (global-hl-line-mode 1)

        (xterm-mouse-mode 1)

        (setq select-enable-clipboard t
              select-enable-primary t
              save-interprogram-paste-before-kill t)

        (setq mouse-yank-at-point t)
      '';

      usePackage = {
        all-the-icons.enable = true;
        bazel.enable = true;
        cloc.enable = true;
        clojure-mode.enable = true;
        devdocs.enable = true;
        git-link.enable = true;
        git-timemachine.enable = true;
        haskell-mode.enable = true;
        julia-mode.enable = true;
        nix-mode.enable = true;
        prism.enable = true;
        rainbow-mode.enable = true;
        rust-mode.enable = true;
        smartparens.enable = true;
        solidity-mode.enable = true;
        symbol-overlay.enable = true;
        typescript-mode.enable = true;
        vterm.enable = true;
        vundo.enable = true;

        evil = {
          enable = true;
          init = ''
            (setq evil-want-keybinding nil
                  evil-want-Y-yank-to-eol t
                  evil-search-wrap t
                  evil-regexp-search t)
          '';
          config = ''
            (evil-mode)
          '';
        };

        evil-collection = {
          enable = true;
          after = [ "evil" ];
          config = ''
            (evil-collection-init)
          '';
        };

        evil-mc = {
          enable = true;
          config = ''
            (global-evil-mc-mode 1)
          '';
        };

        color-identifiers-mode = {
          enable = true;
          config = ''
            (global-color-identifiers-mode)
          '';
        };

        coterm = {
          enable = true;
          config = ''
            (coterm-mode)
          '';
        };

        gruvbox-theme = {
          enable = true;
          config = ''
            (load-theme 'gruvbox-dark-medium)
          '';
        };

        general = {
          enable = true;
          config = ''
            (general-evil-setup t)

            (general-define-key
              :states 'motion
              :prefix "SPC"
              :keymaps 'override
              "SPC" 'save-buffer
              "g" 'magit
              "w" 'evil-window-map
              "p" 'projectile-command-map
              "s i" 'symbol-overlay-put
              "s n" 'symbol-overlay-switch-forward
              "s p" 'symbol-overlay-switch-backward
              "s m" 'symbol-overlay-mode
              "s x" 'symbol-overlay-remove-all
              "b b" 'consult-buffer
              "b e" 'eval-buffer
              "b k" 'kill-buffer
              "b l" 'list-buffers
              "/ f" 'find-file
              "/ r" 'consult-ripgrep
              "/ g" 'consult-git-grep
              "k f" 'describe-function
              "k v" 'describe-variable
              "k s" 'describe-symbol)

            (general-define-key
             :keymaps 'override
             "M-/" 'avy-goto-char-timer
             "C-." 'embark-act)

            (general-def 'normal
              "u" 'undo-fu-only-undo
              "C-r" 'undo-fu-only-redo
              "/" 'consult-line)

            (general-def 'visual
              "A" 'evil-mc-make-cursor-in-visual-selection-end
              "I" 'evil-mc-make-cursor-in-visual-selection-beg)
          '';
        };

        highlight-thing = {
          enable = true;
          config = ''
            (global-highlight-thing-mode)
          '';
        };

        indent-guide = {
          enable = true;
          config = ''
            (indent-guide-global-mode)
          '';
        };

        literate-calc-mode = {
          enable = true;
          config = ''
            (setq literate-calc-mode-idle-time 0.1)
            (literate-calc-mode)
          '';
        };

        frames-only-mode = {
          enable = true;
          config = ''
            (frames-only-mode)
          '';
        };

        yasnippet = {
          enable = true;
          config = ''
            (yas-global-mode)
          '';
        };

        yasnippet-snippets = {
          enable = true;
          after = [ "yasnippet" ];
        };

        avy = {
          enable = true;
        };

        blamer = {
          enable = true;
          config = ''
            (global-blamer-mode 1)
          '';
        };

        hyperbole = {
          enable = true;
        };

        undo-fu = {
          enable = true;
        };

        undo-fu-session = {
          enable = true;
          config = ''
            (setq undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'"))
            (global-undo-fu-session-mode)
          '';
        };

        smooth-scrolling = {
          enable = true;
          config = ''
            (setq smooth-scrolling-margin 5)
            (smooth-scrolling-mode)
          '';
        };

        projectile = {
          enable = true;
          config = ''
            (projectile-mode)
          '';
        };

        which-key = {
          enable = true;
          config = ''
            (setq which-key-idle-delay 0.01)
            (which-key-mode)
          '';
        };

        smex = {
          enable = true;
          config = ''
            (smex-initialize)
          '';
        };

        treemacs = {
          enable = true;
        };

        treemacs-evil = {
          enable = true;
          after = [ "treemacs" "evil" ];
        };

        treemacs-projectile = {
          enable = true;
          after = [ "treemacs" "projectile" ];
        };

        treemacs-icons-dired = {
          enable = true;
          after = [ "treemacs" "dired" ];
          config = ''
            (treemacs-icons-dired-mode)
          '';
        };

        hl-todo = {
          enable = true;
          config = ''
            (global-hl-todo-mode)
          '';
        };

        magit = {
          enable = true;
        };

        magit-todos = {
          enable = true;
          config = ''
            (magit-todos-mode)
          '';
        };

        direnv = {
          enable = true;
          config = ''
            (direnv-mode)
          '';
        };

        rainbow-delimiters = {
          enable = true;
          config = ''
            (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
          '';
        };

        diff-hl = {
          enable = true;
          config = ''
            (global-diff-hl-mode)
          '';
        };

        savehist = {
          enable = true;
          config = ''
            (savehist-mode)
          '';
        };

        orderless = {
          enable = true;
          config = ''
            (setq completion-styles '(orderless basic)
                  completion-category-defaults nil
                  completion-category-overrides '((file (styles partial-completion))))
          '';
        };

        embark = {
          enable = true;
          after = [ "frames-only-mode" ];

          init = ''
            (setq prefix-help-command #'embark-prefix-help-command)
            (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
          '';

          config = ''
            ;; Hide the mode line of the Embark live/completions buffers
            (add-to-list 'display-buffer-alist
                         '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                           nil
                           (window-parameters (mode-line-format . none))))

             (add-to-list 'frames-only-mode-use-window-functions
                          'embark-act)
          '';
        };

        embark-consult = {
          enable = true;
          hook = [ "(embark-collect-mode . consult-preview-at-point-mode)" ];
        };

        corfu = {
          enable = true;
          config = ''
            (setq
              corfu-cycle t
              corfu-auto t)
            (global-corfu-mode)
          '';
        };

        corfu-terminal = {
          enable = true;
          config = ''
            (unless (display-graphic-p)
              (corfu-terminal-mode +1))
          '';
        };

        cape = {
          enable = true;
          init = ''
            (add-to-list 'completion-at-point-functions #'cape-dabbrev)
            (add-to-list 'completion-at-point-functions #'cape-file)
            (add-to-list 'completion-at-point-functions #'cape-elisp-block)
            (add-to-list 'completion-at-point-functions #'cape-history)
            ;; (add-to-list 'completion-at-point-functions #'cape-keyword)
            ;; (add-to-list 'completion-at-point-functions #'cape-tex)
            ;; (add-to-list 'completion-at-point-functions #'cape-sgml)
            ;; (add-to-list 'completion-at-point-functions #'cape-rfc1345)
            (add-to-list 'completion-at-point-functions #'cape-abbrev)
            ;; (add-to-list 'completion-at-point-functions #'cape-dict)
            ;; (add-to-list 'completion-at-point-functions #'cape-elisp-symbol)
            ;; (add-to-list 'completion-at-point-functions #'cape-line)
          '';
        };

        marginalia = {
          enable = true;
          config = ''
            (marginalia-mode)
          '';
        };

        consult = {
          enable = true;
        };

        vertico = {
          enable = true;
          config = ''
            (vertico-mode)
          '';
        };

        whitespace-cleanup-mode = {
          enable = true;
          config = ''
            (global-whitespace-cleanup-mode)
          '';
        };
      };

      postlude = ''
        (setq gc-cons-threshold (* 2 1000 1000))
      '';
    };
  };


  exa = {
    enable = true;
    enableAliases = true;
  };

  foot = {
    enable = true;
    server.enable = true;

    settings = {
      main = {
        term = "xterm-256color";
        font = "Tamsyn:size=10";
        dpi-aware = "yes";
      };

      mouse = {
        hide-when-typing = "yes";
      };

      colors = {
        background = "282828";
        foreground = "ebdbb2";
        regular0 = "282828";
        regular1 = "cc241d";
        regular2 = "98971a";
        regular3 = "d79921";
        regular4 = "458588";
        regular5 = "b16286";
        regular6 = "689d6a";
        regular7 = "a89984";
        bright0 = "928374";
        bright1 = "fb4934";
        bright2 = "b8bb26";
        bright3 = "fabd2f";
        bright4 = "83a598";
        bright5 = "d3869b";
        bright6 = "8ec07c";
        bright7 = "ebdbb2";
      };
    };
  };

  gh = {
    enable = false;
  };

  gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
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
        syntax-theme = "Dracula";
        line-numbers = true;
      };
    };

    extraConfig = {
      init = {
        defaultBranch = "master";
      };

      credential = {
        helper = "store";
      };

      core = {
        editor = "${config.home.sessionVariables.EDITOR}";
      };
    };
  };

  ion = {
    enable = true;
  };

  mpv = {
    enable = true;
    config = {
      #gpu-api = "vulkan";
      #gpu-context = "wayland";
      #gpu-context = "x11vk";
      #hwdec = "vaapi";
      #profile = "gpu-hq";
      #spirv-compiler = "shaderc";
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

  readline = {
    enable = true;
    extraConfig = ''
      set editing-mode vi
    '';
  };

  starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[x](bold red)";
        vicmd_symbol = "[<](bold green)";
      };
    };
  };

  waybar = {
    enable = true;
    settings = {
      mainBar = {
        # setting monitor to desky to force a rebuild :)
        output = [ "HDMI-A-1" ];
        layer = "top";
        position = "top";
        height = 24;
        modules-left = [
          "wlr/workspaces"
          "wlr/mode"
          "custom/weather" 
          "custom/spotify"
        ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "pulseaudio"
          "network"
          "temperature"
          "cpu"
          "memory"
          "battery"
          "tray"
          "clock"
        ];
        "wlr/workspaces" = {
          disable-scroll = true;
          all-outputs = false;
          on-click = "activate";
          format = "{icon}";
          format-icons = {
              "1" = "󰖟";
              "2" = "";
              "active" = "";
              "default" = "󰝦";
          };
        };
        "wlr/mode" = { format = "<span style=\"italic\">{}</span>"; };
        "tray" = {
          # "icon-size" = 21,
          "spacing" = 10;
        };
        "clock" = { "format-alt" = "{:%Y-%m-%d}"; "on-click" = ""; };
        "cpu"= { 
          "format"= "{usage}% 󰍛"; 
        };
        "memory"= { "format"= "{}% "; };

        "temperature" = { 
          "critical-threshold" = 80;  
          "format" = "{}℃  󰏈"; 
          "format-critical" = "{}℃ 󰇺";
          "interval" = 5;
        };

        "battery"= {
            "bat"= "BAT0";
            "states"= {
                # "good"= 95;
                "warning"= 30;
                "critical"= 15;
            };
            "format"= "{capacity}% {icon}";
            # "format-good"= ""; # An empty format will hide the module
            # "format-full"= "";
            "format-icons"= ["" "" "" "" ""];
        };
        "network"= {
            # "interface"= "wlp2s0"; # (Optional) To force the use of this interface
            "format-wifi"= "{essid} ({signalStrength}%) ";
            "format-ethernet"= "{ifname}= {ipaddr}/{cidr} ";
            "format-disconnected"= "Disconnected ⚠";
        };
        "pulseaudio"= {
            #"scroll-step"= 1;
            "format"= "{volume}% {icon}";
            "format-bluetooth"= "{volume}% {icon}";
            "format-muted"= "";
            "format-icons"= {
                "headphones" = "";
                "handsfree" = "";
                "headset" = "";
                "phone" = "";
                "portable" = "";
                "car" = "";
                "default" = [ "" "" ];
            };
            "on-click"= "pavucontrol";
        };
        "custom/spotify"= {
            "format"= " {}";
            "max-length"= 40;
            "interval"= 10; # Remove this if your script is endless and write in loop
            "exec"= "$HOME/.config/waybar/mediaplayer.sh 2> /dev/null"; # Script in resources folder
            "exec-if"= "pgrep spotify || pgrep ncspot";
        };
        "hyprland/window" = { 
          "format" = {}; 
          "seperate-outputs" = true;
        };
        "custom/weather" = {
          format = "{}";
          exec = "curl -s wttr.in/\?format=\"Urbana:+%C,+%t+%w\"";
          interval = 1800;
        };
      };
    };
  };

  zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableVteIntegration = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

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
    '';

    initExtraBeforeCompInit = ''
      autoload -Uz zcalc
      autoload -Uz edit-command-line

      zle -N edit-command-line
      bindkey -M vicmd v edit-command-line
      bindkey -v '^?' backward-delete-char

      setopt globdots
      setopt autopushd
    '';
  };
}
