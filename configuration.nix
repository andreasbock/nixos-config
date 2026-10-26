# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # --- Boot ------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --- Networking / locale --------------------------------------------
  networking.hostName = "nixos"; # Define your hostname.
  # Disabled: wpa_supplicant conflicts with NetworkManager (build fails
  # with an assertion). NetworkManager handles wifi itself.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # --- Desktop ---------------------------------------------------------
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "dk";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # --- Users -----------------------------------------------------------
  programs.zsh.enable = true; # needed system-wide for zsh as a login shell

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."andreas" = {
    isNormalUser = true;
    description = "Andreas Asp Bock";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Hack: monospace font used by the Konsole profile
  fonts.packages = [ pkgs.hack-font ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes (this config is built from ./flake.nix).
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Lets prebuilt binaries (pip/uv wheels with C extensions, VS Code
  # extensions, downloaded toolchains) find a dynamic linker on NixOS.
  programs.nix-ld.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
     git
     pkgs.neovim
     wget
     curl
     google-chrome
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

  # ======================================================================
  # User environment (Home Manager), ported from ~/tmp/dotfiles
  # ======================================================================

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # Existing ~/.zshrc etc. get renamed to *.backup instead of failing the build
  home-manager.backupFileExtension = "backup";

  home-manager.users.andreas = {
    home.packages = with pkgs; [
      # --- Python ---
      python3
      uv
      poetry
      ruff
      pyright

      # --- C / C++ ---
      # gcc is the compiler; clang-tools gives clangd/clang-format/clang-tidy.
      # Not adding clang itself: its cc/c++ wrappers collide with gcc's.
      # Use `nix shell nixpkgs#clang` (or a project flake) when you need it.
      gcc
      clang-tools
      gnumake
      cmake
      ninja
      meson
      pkg-config
      gdb
      valgrind
      bear # generates compile_commands.json for clangd

      # --- General ---
      ripgrep
      fd
      jq
      colordiff
      wl-clipboard # wl-copy, used by tmux copy mode (Plasma 6 runs Wayland)
      tmux-mem-cpu-load

      # --- LaTeX (includes latexpand) ---
      (texlive.combine { inherit (texlive) scheme-medium latexpand; })

      # --- Apps ---
      firefox
    ];

    # was .zshenv: only ~/.local/bin survives; poetry/homebrew/TeXShop paths are macOS-only
    home.sessionPath = [ "$HOME/.local/bin" ];

    # --- .aliases ---
    programs.zsh = {
      enable = true;
      shellAliases = {
        up = "cd ..";
        ll = "ls -la";
        l = "ls -1";
        lr = "l -R";
        diff = "colordiff";
        gst = "git status";
        gb = "git branch";
        gl = "git log";
        gd = "git diff";
        vi = "nvim";
        vim = "nvim";
        nixrb = "sudo nixos-rebuild build"; 
        nixsw = "sudo nixos-rebuild switch"; 
        mcm = "make clean; clear; make";
        "py.test" = "python -m pytest";
      };
    };

    # --- .gitconfig + .gitignore_global ---
    programs.git = {
      enable = true;
      ignores = [ "*~" ".DS_Store" ];
      settings = {
        user.name = "Andreas Bock";
        # user.email = "...";
        core.autocrlf = "input";
        rebase.autoStash = true;
        alias = {
          st = "status";
          ci = "commit -v";
          co = "checkout";
          br = "branch";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          pullm = "pull --rebase origin main";
          pushf = "push --force-with-lease";
        };
      };
    };

    # --- .vimrc (plugins come from nixpkgs instead of pathogen) ---
    programs.vim = {
      enable = true;
      plugins = [ pkgs.vimPlugins.syntastic ];
      extraConfig = ''
        syntax on
        filetype plugin indent on

        set statusline+=%#warningmsg#
        set statusline+=%{SyntasticStatuslineFlag()}
        set statusline+=%*

        let g:syntastic_always_populate_loc_list = 1
        let g:syntastic_auto_loc_list = 1
        let g:syntastic_check_on_open = 1
        let g:syntastic_check_on_wq = 0
      '';
    };

    # --- nvim/init.vim ---
    programs.neovim = {
      enable = true;
      extraConfig = ''
        set tabstop=4
        set shiftwidth=4
        set softtabstop=4
        set expandtab
        set autoindent
        set smartindent

        syntax on
        filetype plugin indent on

        set number
        set relativenumber

        set incsearch
        set hlsearch
        set ignorecase
        set smartcase

        set cursorline
        set wrap
        set scrolloff=8

        set termguicolors
        colorscheme vim
      '';
    };

    # --- .tmux.conf ---
    # Prefix Ctrl-a. Ctrl-a | / - split, h/j/k/l move, arrows resize,
    # z zoom, a last pane, x kill, Space cycle layouts, r reload.
    programs.tmux = {
      enable = true;
      prefix = "C-a";
      keyMode = "vi";
      mouse = true;
      extraConfig = ''
        bind '|' split-window -h -c "#{pane_current_path}"
        bind '-' split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"

        bind a last-pane
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind z resize-pane -Z

        bind -r Left resize-pane -L 2
        bind -r Right resize-pane -R 2
        bind -r Down resize-pane -D 2
        bind -r Up resize-pane -U 2

        bind , command-prompt "rename-window '%%'"
        bind x confirm-before "kill-pane"
        bind Space next-layout
        bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded"

        # vi copy mode -> Wayland clipboard
        bind '[' copy-mode
        bind ']' paste-buffer
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
        bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "wl-copy"

        set -g status-interval 2
        set -g status-right "#(tmux-mem-cpu-load 2) #H"

        # Copying/pasting
        set -g mouse on
        set -g set-clipboard on

        # Bind 'y' in vi-copy mode to pipe to wl-copy
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
        bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "wl-copy"
      '';
    };

    # --- Per-project dev shells: `use flake` in a repo's .envrc ---
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # --- PDF viewer: vim keys, auto-reloads (good for LaTeX) ---
    programs.zathura = {
      enable = true;
      options.selection-clipboard = "clipboard";
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications."application/pdf" = [ "org.pwmt.zathura.desktop" ];
    };

    # --- KDE Plasma settings (plasma-manager) ---
    programs.plasma.enable = true;

    # --- Fonts ---
    programs.plasma.fonts = {
      general    = { family = "Noto Sans"; pointSize = 12; };  # default is 10
      menu       = { family = "Noto Sans"; pointSize = 12; };
      toolbar    = { family = "Noto Sans"; pointSize = 12; };
      windowTitle = { family = "Noto Sans"; pointSize = 12; };
      small      = { family = "Noto Sans"; pointSize = 10; };  # default is 8
      fixedWidth = { family = "Hack";      pointSize = 12; };  # editor/monospace font
    };

    programs.plasma.shortcuts.kwin = {
      "Window Maximize" = "Meta+M";
      "Window Minimize" = "Meta+D";
      "Show Desktop"    = "none";
      "Walk Through Windows"           = [ "Ctrl+Tab" "Alt+Tab" ];
      "Walk Through Windows (Reverse)" = [ "Ctrl+Shift+Tab" "Alt+Shift+Tab" ];
    };

    # Kate: dark window colors + dark editor theme
    programs.kate = {
      enable = true;
      ui.colorScheme = "Breeze Dark";
      editor.theme.name = "Breeze Dark";
    };

    # Dolphin: Details (list) view for every folder, like Finder's list view
    programs.plasma.configFile.dolphinrc.General.GlobalViewProps = true;
    programs.plasma.dataFile."dolphin/view_properties/global/.directory".Dolphin = {
      Version = 4;
      ViewMode = 1; # 0 = icons, 1 = details, 2 = compact
    };

    # Alacritty: chrome-free terminal that opens straight into tmux.
    # No title bar: move with Meta+drag, resize with Meta+right-drag.
    programs.alacritty = {
      enable = true;
      settings = {
        terminal.shell.program = "${pkgs.tmux}/bin/tmux";

        # --- Add this window block ---
        window = {
          decorations = "None";
          opacity = 1.0;     # Explicitly forces 100% opaque solid background
          blur = false;      # Disables background compositor blending
        };

        font = {
          normal.family = "Hack";
          size = 12;
        };
        # https://terminalcolors.com/themes/github/dark/ (their Alacritty file)
        colors = {
          primary = { foreground = "#e6edf3"; background = "#000000"; };
          cursor = { text = "#000000"; cursor = "#e6edf3"; };
          selection = { text = "#e6edf3"; background = "#264f78"; };
          normal = {
            black = "#484f58"; red = "#ff7b72"; green = "#3fb950"; yellow = "#d29922";
            blue = "#58a6ff"; magenta = "#bc8cff"; cyan = "#39c5cf"; white = "#b1bac4";
          };
          bright = {
            black = "#6e7681"; red = "#ffa198"; green = "#56d364"; yellow = "#e3b341";
            blue = "#79c0ff"; magenta = "#d2a8ff"; cyan = "#56d4dd"; white = "#ffffff";
          };
        };
      };
    };

    # Default terminal for KDE (Ctrl+Alt+T, Dolphin "Open Terminal Here")
    programs.plasma.configFile.kdeglobals.General = {
      TerminalApplication = "alacritty";
      TerminalService = "Alacritty.desktop";
    };

    # Window decoration: classic KDE 3 "Plastik" (box/line buttons instead of
    # Breeze's chevrons). Ships with kdePackages.aurorae, installed by Plasma.
    programs.plasma.workspace.windowDecorations = {
      library = "org.kde.kwin.aurorae";
      theme = "kwin4_decoration_qml_plastik";
    };

    programs.home-manager.enable = true;

    # Launch these at login
    xdg.configFile."autostart/alacritty.desktop".source =
      "${pkgs.alacritty}/share/applications/Alacritty.desktop";
    xdg.configFile."autostart/google-chrome.desktop".source =
      "${pkgs.google-chrome}/share/applications/google-chrome.desktop";

    # Start each login with an empty session, so Plasma doesn't also
    # reopen whatever was running when you last logged out
    # programs.plasma.configFile.ksmserverrc.General.loginMode = "emptySession";

    # Do not change after first install.
    home.stateVersion = "26.05";
  };
}
