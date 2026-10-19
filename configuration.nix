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
        vi = "vim";
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
        colorscheme desert
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

    # Kate: dark window colors + dark editor theme
    programs.kate = {
      enable = true;
      ui.colorScheme = "Breeze Dark";
      editor.theme.name = "Breeze Dark";
    };

    # Window decoration: classic KDE 3 "Plastik" (box/line buttons instead of
    # Breeze's chevrons). Ships with kdePackages.aurorae, installed by Plasma.
    programs.plasma.workspace.windowDecorations = {
      library = "org.kde.kwin.aurorae";
      theme = "kwin4_decoration_qml_plastik";
    };

    programs.home-manager.enable = true;

    # Do not change after first install.
    home.stateVersion = "26.05";
  };
}
