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
    ./anki.nix
    ./boot.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

/*     nixpkgs.overlays = [
      (final: prev: {
        calibre = prev.calibre.overrideAttrs (oldAttrs: {
          # 1. Add theme packages to Calibre's runtime dependencies
          buildInputs = oldAttrs.buildInputs ++ [
            final.adwaita-qt6 # Provides the actual theme files
          ];

          # 2. Add the Qt wrapper hook to its native build inputs
          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
            final.qt6.wrapQtAppsHook
          ];

        });
      })
    ]; */

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "sv-latin1";
  };

  time.timeZone = "Europe/Stockholm";

  # jp keyboard
  jpInput = true;

  environment.variables.EDITOR = "hx";

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
  # make nvim default editor
  # environment.variables.EDITOR = "nvim";

  #nixpkgs.overlays = [
  #  # The home manager neovim package expects it unwrapped before configuration is applied and i was trying to give it a completed package. All i had to do after overlay was to add it to system packages
  #  (final: prev: { neovim = inputs.custom-neovim.packages.x86_64-linux.default; })
  #];
  environment.systemPackages = with pkgs; [
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
    pavucontrol
    #neovim
    lean4
    cargo
    rustc
    chromium

    # Particularily to get gnome files to recognize USB devices (1)
    usbutils # Tools for working with USB devices, such as lsusb
    udiskie # Removable disk automounter for udisks
    udisks # Daemon, tools and libraries to access and manipulate disks, storage devices and technologies
  ];


  # particulariy to be able to unzip files in gnome files
  programs.file-roller.enable = true;


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
  # for some reason qt theme is defined in nixos moduels while gtk is in home manager
/*   qt = {
    style = "adwaita-dark";
  }; */
}
