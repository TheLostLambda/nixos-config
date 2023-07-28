# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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

  # Bootloader
  boot.loader.systemd-boot.enable = true;
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
    eog         # image viewer
    gedit       # text editor
    simple-scan # document scanner
    totem       # video player
    yelp        # help viewer
    geary       # email client
    seahorse    # password manager

    # these should be self explanatory
    gnome-contacts gnome-font-viewer gnome-logs gnome-maps gnome-music
    pkgs.gnome-photos gnome-screenshot pkgs.gnome-connections pkgs.gnome-tour
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Absolutely do not ask for any passwords graphically...
  programs.ssh.askPassword = "";

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
      firefox
      mailspring
      emacs
      spotify
      logseq
      gimp
      bitwarden
      # cq-editor
      discord
      furtherance
    ];
  };

  # Can this be merged with the above?
  home-manager.users.tll = { pkgs, ... }: {
    home.stateVersion = "23.05";
    programs.fish.enable = true;
    programs.starship.enable = true;
    programs.git = {
      enable = true;
      userName = "Brooks J Rady";
      userEmail = "b.j.rady@gmail.com";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    helix
    zellij
    fd
    ripgrep
    bat
  ];

  # Whitelist a number of nonfree applications
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "spotify"
    "discord"
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon
  services.openssh.enable = true;

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
