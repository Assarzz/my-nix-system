{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ./users.nix
    #./graphics.nix
    ./niri.nix
    ./steam.nix
    ./sound.nix
  ];

  #   nixpkgs.overlays = [
  #   inputs.nix-vscode-extensions.overlays.default
  # ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # boot stuff
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    #font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # networking
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.

  # extra udev rule to flash zsa keyboard with oryx
  services.udev.extraRules = ''
    # Rules for Oryx web flashing and live training
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

    # Keymapp Flashing rules for the Voyager
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
  '';

  # wayland support for vscode in particular
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    anki-bin
    evince
    calibre
    wget
    nautilus
    (import ../update-git.nix { inherit pkgs; })
    xwayland-satellite
    keepassxc
    pulseaudio # for pactl utility
    dua
    tlp
    glances
    nixpkgs-fmt

  ];

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
    tlp.enable = true;

  };

  # fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];
}
