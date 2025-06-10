{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./users.nix
    ./niri.nix
    ./steam.nix
    ./sound.nix
    ./nas.nix
    ./jp-input.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Boot settings
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "sv-latin1";
  };

  time.timeZone = "Europe/Stockholm";

  # jp keyboard
  jpInput = true;

  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Extra udev rule to flash zsa keyboard with oryx
  services.udev.extraRules = ''
    # Rules for Oryx web flashing and live training
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

    # Keymapp Flashing rules for the Voyager
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
  '';

  # Wayland support for vscode in particular
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
    nixfmt-rfc-style
    element-desktop

    # Particularily to get gnome files to recognize USB devices (1)
    usbutils # Tools for working with USB devices, such as lsusb
    udiskie # Removable disk automounter for udisks
    udisks # Daemon, tools and libraries to access and manipulate disks, storage devices and technologies
  ];

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
    tlp.enable = true;

    # (1)
    gvfs.enable = true;
    udisks2.enable = true;
    devmon.enable = true;

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
