# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# FIXME: Make all of this configuration into a Flake!

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan
      ./hardware-configuration.nix
      # Include Home Manager (need to move to a flake!)
      <home-manager/nixos>
    ];

  # Enable Nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Filesystem details for synchrotron
  # FIXME: Could use some Nix language refactoring!
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/27289c95-44b5-4edb-9b1a-2518d997607c";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/27289c95-44b5-4edb-9b1a-2518d997607c";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/27289c95-44b5-4edb-9b1a-2518d997607c";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3D10-6079";
      fsType = "vfat";
    };

  # Bootloader
  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
    default = "saved";
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the latest Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Define your hostname
  networking.hostName = "synchrotron";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "Europe/London";

  # Select internationalisation properties
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

  # Enable the X11 windowing system
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Enable the GNOME Desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Clean up the default GNOME install a bit...
  environment.gnome.excludePackages = with pkgs.gnome; [
    cheese      # photo booth
    gedit       # text editor
    simple-scan # document scanner
    totem       # video player
    yelp        # help viewer
    geary       # email client
    seahorse    # password manager

    # these should be self explanatory
    gnome-contacts gnome-logs gnome-maps gnome-music
    pkgs.gnome-photos gnome-screenshot pkgs.gnome-connections pkgs.gnome-tour
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Absolutely do not ask for any passwords graphically...
  programs.ssh.askPassword = "";

  # Enable gpg to actually decrypt things
  programs.gnupg.agent.enable = true;

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable sound with pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable the fish shell
  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tll = {
    isNormalUser = true;
    description = "Brooks J Rady";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      # cq-editor
      audacity
      bitwarden
      blender
      calibre
      darktable
      discord
      emacs
      firefox
      fragments
      furtherance
      gimp
      google-chrome
      handbrake
      helvum
      hunspell
      hunspellDicts.en_GB-large
      hunspellDicts.en_US-large
      inkscape
      kicad
      krita
      libreoffice
      logseq
      mailspring
      mozillavpn # Not working?
      obs-studio
      prusa-slicer
      rnote
      rstudio
      scribus
      slack
      snapper # This feels like it would have some NixOS config!
      spotify
      thonny
      tor-browser-bundle-bin
      vlc
      vscode
      wireshark
      zotero
    ];
  };

  # Can this be merged with the above?
  home-manager.users.tll = { pkgs, ... }: {
    home.stateVersion = "23.05";

    # Create a couple of files for Syncthing
    home.file.".stignore".text = ''
      #include /.stignore.txt
    '';

    home.file.".stignore.txt".text = ''
      !/.stignore.txt
      !/Documents
      !/Music
      !/Pictures
      !/Videos
      /*
    '';

    programs = {
      direnv.enable = true;
      # nix-direnv.enable = true; Is this something that's still needed?
      fish.enable = true;
      starship.enable = true;

      git = {
        enable = true;
        userName = "Brooks J Rady";
        userEmail = "b.j.rady@gmail.com";
      };

      helix = {
        enable = true;
        # defaultEditor = true;
        settings = {
          theme = "gruvbox";
          editor = {
            line-number = "relative";
            lsp.display-inlay-hints = true;
          };
        };
      };
    };

    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = [
          "firefox.desktop"
          "spotify.desktop"
          "logseq.desktop"
          "emacs.desktop"
          "org.gnome.Nautilus.desktop"
          "org.gnome.Console.desktop"
        ];
      };
      
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      
      "org/gnome/mutter" = {
        dynamic-workspaces = true;
        edge-tiling = true;
        workspaces-only-on-primary = true;
      };

      "org/gnome/desktop/input-sources" = {
        xkb-options = [ "compose:ralt" ];
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>t";
        command = "kgx";
        name = "Launch Console";
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ast-grep
    bat
    bottom
    delta
    erdtree
    eza
    fd
    gnupg
    helix
    htop
    hyperfine
    inxi
    killall
    lrzip
    mosh
    mozwire
    nmap
    ripgrep
    rmlint
    speedtest-cli
    tealdeer
    tokei
    watchexec
    wireguard-tools
    zellij
  ];

  # Whitelist a number of nonfree applications
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "spotify"
    "discord"
    "google-chrome"
    "slack"
    "vscode"
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon
  services.openssh.enable = true;

  # Enable and configure Syncthing
  services.syncthing = {
    enable = true;
    user = "tll";
    dataDir = "/home/tll";
    configDir = "/home/tll/.config/syncthing";
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices = {
        "CUBE" = { id = "6KBEA6K-HANHU7H-EYOAZGE-5BQ3LFB-WSKRIH7-FPLOZY3-DYAINAM-AGWEEAE"; };
        "Nord II" = { id = "VOSWV6Y-FQHZNEH-WIMSUQQ-URKKD2M-3BSWMS2-4OKEYVU-EHQEN5W-AC7RLQA"; };
        "Tokamak" = { id = "JLMFDTX-B4ZREF3-YRHQYCL-Z5IC5PK-27K3C4S-3PUQ3TQ-AV7GMB7-P4EWWAY"; };
        "VCS" = { id = "RYUZGVO-HXLGJNY-GGSLFHH-MGIIYG7-TMHMPEQ-6QFKH7B-GZU7XFB-22SKQAT"; };
      };
      folders = {
        "Documents" = {
          path = "/home/tll";
          devices = [ "CUBE" "Nord II" "Tokamak" "VCS" ];
          ignorePerms = false;
        };
      };
    };
  };
  
  # Enable automatic package upgrades
  system.autoUpgrade.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
