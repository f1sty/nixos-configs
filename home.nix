{
  config,
  pkgs,
  lib,
  ...
}:
  let
    dotfiles = "${config.home.homeDirectory}/nixos/config";
    create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

    configs = {
      erlang_ls = "erlang_ls";
      nvim = "nvim";
      procps = "procps";
      aria2 = "aria2";
      flameshot  = "flameshot";
      clangd = "clangd";
    };
  in {
  home.username = "f1sty";
  home.homeDirectory = "/home/f1sty";
  home.stateVersion = "25.11";
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];
  home.packages = with pkgs; [
    (slstatus.overrideAttrs (_: {
      src = ./config/slstatus;
    }))
  ];

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      fonts = {
        names = ["Iosevka Nerd Font Mono" "Font Awesome 7 Free"];
        style = "Regular";
        size = 8.0;
      };
      workspaceAutoBackAndForth = true;
      window = {
        hideEdgeBorders = "smart";
        titlebar = true;
      };
      modifier = "Mod4";
      terminal = "alacritty -e tmux";
      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs config-main.toml";
        }
      ];
      keybindings = let
        modifier = config.xsession.windowManager.i3.config.modifier;
      in
        lib.mkOptionDefault {
          "${modifier}+p" = "exec \"${pkgs.rofi}/bin/rofi -modi run,drun -show run\"";
          "${modifier}+w" = "exec --no-startup-id ${pkgs.firefox}/bin/firefox";
          "${modifier}+v" = "exec --no-startup-id ${pkgs.clipmenu}/bin/clipmenu";
          "${modifier}+Shift+s" = "exec --no-startup-id ${pkgs.flameshot}/bin/flameshot gui";
          "${modifier}+Shift+c" = "kill";
          "XF86AudioRaiseVolume" = "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 2%+";
          "XF86AudioLowerVolume" = "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 2%-";
          "XF86AudioMute" = "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec --no-startup-id ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SOURCE@ toggle";
          "XF86MonBrightnessUp" = "exec --no-startup-id ${pkgs.brightnessctl}/bin/brightnessctl --device=intel_backlight set 5%+";
          "XF86MonBrightnessDown" = "exec --no-startup-id ${pkgs.brightnessctl}/bin/brightnessctl --device=intel_backlight set 5%-";
        };
    };
  };

  programs.rmpc.enable = true;
  programs.readline = {
    enable = true;
    extraConfig = ''
      set editing-mode vi
      $if mode=vi
      set keymap vi-command
      Control-l: clear-screen
      set keymap vi-insert
      Control-l: clear-screen
      $endif
    '';
  };

  programs.neovim = {
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      shopt -so vi
      shopt -so noclobber
      shopt -so pipefail
      source <(fzf --bash)
    '';
    enableVteIntegration = true;
    historyControl = ["erasedups"];
    historyFileSize = null;
    historySize = null;
    sessionVariables = {
      ERL_AFLAGS = "-kernel shell_history enabled";
      CM_LAUNCHER = "rofi";
      PS1="\\[\\033[1;32m\\][\\[\\e]0;\\u@\\h: \\w\\a\\]\\u@\\h:\\w]\$\\[\\033[0m\\] ";
    };
    shellOptions = [
      "checkwinsize"
      "histappend"
      "autocd"
      "expand_aliases"
      "cdspell"
      "dirspell"
      "globstar"
    ];
    shellAliases = {
      ip = "ip -c";
      nxs = "nix search nixpkgs";
      nxr = "nixos-rebuild switch --sudo --flake";
      nxo = "nix-store --optimise";
      nxc = "nix-collect-garbage -d";
      nxg = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Yurii Skrynnykov";
        email = "f1st@pm.me";
      };
      alias = {
        co = "checkout";
        cv = "commit -v";
        sw = "switch";
        st = "status";
        unstage = "restore --staged";
        last = "log -1 HEAD";
        last5 = "log -5 HEAD";
        a = "add";
        aa = "add --all";
        ca = "commit --amend";
        pu = "push";
        pl = "pull";
        prev = "switch -";
        sta = "stash --all";
        bl = "blame -w -C -C -C";
      };
      format = {
        pretty = "format:%C(yellow)%h %Cblue%>(12)%ad %Cgreen%<(7)%aN%Cred%d %Creset%s";
      };
      init = {
        defaultbranch = "main";
      };
      diff = {
        tool = "vimdiff";
        colormoved = "default";
      };
      merge = {
        tool = "vimdiff";
        conflictstyle = "diff3";
      };
      pull = {
        rebase = true;
      };
      rebase = {
        updaterefs = true;
      };
    };
    signing = {
      key = "69A0D533343707A9B8EB9A095EE4C90A985D51B2";
      signByDefault = true;
    };
  };

  programs.mpv = {
    enable = true;
    bindings = {
      h = "seek -5";
      l = "seek 5";
      j = "add volume -2";
      k = "add volume +2";
      ";" = "show-progress";
    };
    scripts = with pkgs.mpvScripts; [youtube-chat mpv-notify-send];
  };

  programs.alacritty = {
    enable = true;
    settings = {
      scrolling.history = 20000;
      font = {
        normal.family = "Iosevka Nerd Font Mono";
        bold.family = "Iosevka Nerd Font Mono";
        italic.family = "Iosevka Nerd Font Mono";
        bold_italic.family = "Iosevka Nerd Font Mono";
        size = 10;
      };
    };
  };

  programs.ripgrep = {
    enable = true;
    arguments = ["--hidden"];
  };

  programs.i3status-rust = {
    enable = true;
    bars = {
      main = {
        blocks = [
          {
            block = "net";
            format = " $icon {$signal_strength $ssid $frequency|Wired connection} ";
          }
          {
            block = "temperature";
            interval = 10;
            chip = "*-isa-*";
          }
          {
            block = "backlight";
          }
          {
            block = "battery";
            format = " $icon $percentage {$time_remaining.dur(hms:true, min_unit:m) |}";
            device = "DisplayDevice";
            driver = "upower";
          }
          {
            block = "memory";
            format = " $icon $mem_used_percents ";
            format_alt = " $icon $swap_used_percents ";
          }
          {
            block = "sound";
          }
          {
            block = "keyboard_layout";
          }
          {
            block = "time";
            format = " $timestamp.datetime(f:'%a %d/%m %R') ";
            interval = 60;
          }
        ];
        icons = "awesome6";
        theme = "gruvbox-dark";
      };
    };
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 100000;
    keyMode = "vi";
    mouse = true;
    shell = "${pkgs.bash}/bin/bash";
    extraConfig = ''
      set -g prefix `
      set -g set-clipboard off
      set -g renumber-windows on
      set -g set-titles on
      set -s copy-command 'xsel -ib'
      set -g status-justify absolute-centre

      BG="#202020",
      FG="#FFDAB9",
      LEFT=""
      RIGHT=""
      RIGHT_CURRENT=""
      LEFT_CURRENT=""

      set -g status-left "\
      #[bg=#505050,fg=#ffeb99] #S \
      #[bg=default,fg=#505050]''${LEFT}"
      set -g status-right "\
      #[bg=default,fg=#505050]''${RIGHT}\
      #[bg=#505050,fg=#c0e9ff] #h "
      set -g status-interval 5
      set -g status-style bg=''${BG},fg=''${FG}
      set -g window-status-format "#I:#W"
      set -g window-status-current-format "\
      #[fg=#303030,bg=default]''${LEFT_CURRENT}\
      #[fg=default,bg=#303030]#I:\
      #[fg=#ff9da4]#W\
      #[fg=#303030,bg=default]''${RIGHT_CURRENT}"

      set -g default-terminal "tmux-256color"
      set -g -a terminal-overrides ",st*:Tc:Ss@,*:RGB"

      set -s focus-events on
      set -s extended-keys on
      set -s escape-time 0

      unbind c-b
      unbind h
      unbind j
      unbind k
      unbind l
      unbind %
      unbind '"'
      unbind c-n
      bind ` send-prefix
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind y display-popup -w 80% -h 80% -E "rmpc"
      bind -r C-h resize-pane -L 1
      bind -r C-j resize-pane -D 1
      bind -r C-k resize-pane -U 1
      bind -r C-l resize-pane -R 1
      bind -r m resize-pane -Z
      bind X confirm kill-window
      bind K confirm kill-server
      bind r source-file ${config.home.homeDirectory}/.config/tmux/tmux.conf \; display "config reloaded"
      bind c-b last-window
      bind b set-option status
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
    '';
  };

  xdg.userDirs = {
    enable = true;
    setSessionVariables = false;
    download = "${config.home.homeDirectory}/downloads";
    desktop = "${config.home.homeDirectory}/downloads";
    documents = "${config.home.homeDirectory}/downloads";
    music = "${config.home.homeDirectory}/media/audio";
    pictures = "${config.home.homeDirectory}/media/images";
    videos = "${config.home.homeDirectory}/media/videos";
    publicShare = "${config.home.homeDirectory}/.local/share";
  };

  services.dunst.enable = true;
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/media/audio";
    extraConfig = ''
      audio_output {
        type        "pipewire"
        name        "PipeWire Sound Server"
      }'';
  };

  xdg.configFile = builtins.mapAttrs
  (name: subpath: {
    source = create_symlink "${dotfiles}/${subpath}";
    recursive = true;
  })
  configs;
}
