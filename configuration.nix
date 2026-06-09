{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      limine = {
        enable = true;
        efiSupport = true;
        maxGenerations = 2;
      };
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true;
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };
  };

  networking.hostName = "combobulator";
  networking.networkmanager.enable = true;
  networking.wireless.enable = true;

  time.timeZone = "Europe/Kyiv";

  systemd.services.NetworkManager-wait-online.enable = false;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    ensureDatabases = [ "f1sty" ];
    ensureUsers = [
      {
        name = "f1sty";
        ensureDBOwnership = true;
      }
    ];
    extensions =
      ps: with ps; [
        postgis
      ];
  };

  services.snmpd = {
    enable = true;
    configText = ''
    agentaddress localhost:161
    rocommunity public
    rwcommunity private
    '';
  };

  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    xkb = {
      layout = "us,ua";
      options = "grp:shifts_toggle,terminate:ctrl_alt_bksp,compose:rctrl";
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status-rust
      ];
    };
    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm.overrideAttrs {
        src = ./dotfiles/dwm;
      };
    };
    displayManager.sessionCommands = ''
    xwallpaper --stretch ~/media/images/wallpapers/train.png
    slstatus &
    '';
  };

  services.displayManager = {
    ly.enable = true;
    defaultSession = "none+i3";
  };

  services.greenclip.enable = true;
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
  services.libinput.enable = true;

  users.users.f1sty = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker" "tty" "vboxusers" "wireshark"];
  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host = {
    enable = true;
    enableKvm = true;
    addNetworkInterface = false;
    enableExtensionPack = true;
  };

  environment.systemPackages = with pkgs; [
    alacritty
    alejandra
    android-file-transfer
    ardour
    aria2
    binwalk
    brightnessctl
    btop
    clang
    clang-tools
    cryptsetup
    delta
    dnsutils
    elixir
    elixir-ls
    erlang
    erlang-language-platform
    fd
    flameshot
    gcc
    ghidra
    git
    gnumake
    go
    gopls
    imv
    ipcalc
    irssi
    jq
    killall
    libreoffice-fresh
    liburing
    lm_sensors
    lsof
    man-pages
    minipro
    mpv
    nasm
    net-snmp
    nethack
    nixd
    nmap
    nnn
    ntfs3g
    pass
    picocom
    powertop
    pwgen
    qemu
    radare2
    remmina
    ripgrep
    rmpc
    rofi
    rustdesk
    rustup
    socat
    sshfs
    st
    tmux
    tree-sitter
    ubridge
    unrar
    unzip
    wget
    weechat
    winbox4
    wireguard-tools
    wireshark
    xdotool
    xsel
    xwallpaper
    yt-dlp
    zig
    zig-shell-completions
    zls
    zoxide
  ];

  programs.nix-index-database.comma.enable = true;
  programs.fzf = {
    fuzzyCompletion = true;
    keybindings = true;
  };
  programs.firefox.enable = true;
  programs.i3lock.enable = true;
  programs.steam.enable = true;

  programs.wireshark = {
    enable = true;
    dumpcap.enable = true;
    usbmon.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withRuby = true;
    withNodeJs = true;
  };


  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    font-awesome
  ];
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
    allowed-users = ["f1sty"];
  };

  hardware.nvidia.open = false;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = false;
  hardware.nvidia.modesetting.enable = true;

  hardware.bluetooth.enable = true;

  systemd.services.nvidia-suspend.enable = true;
  systemd.services.nvidia-resume.enable = true;
  systemd.services.nvidia-hibernate.enable = true;

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.openssh.enable = true;
  services.upower.enable = true;

  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;

  networking.firewall.allowedTCPPorts = [22];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;
  # system.copySystemConfiguration = true;

  system.stateVersion = "25.11";
}
