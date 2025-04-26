{ config, lib, pkgs, ... }:
{
  imports = [
    ./users.nix
    #./graphics.nix
    ./niri.nix
    ./steam.nix
  ];

    nixpkgs.overlays = [
    nix-vscode-extensions.overlays.default
  ];
    extensions = with pkgs.vscode-marketplace; [
    # Search for vscode-extensions on https://search.nixos.org/packages
    #dracula-theme.theme-dracula
    jnoortheen.nix-ide
    #gruntfuggly.todo-tree
    #llvm-vs-code-extensions.vscode-clangd
    #ms-vscode-remote.remote-ssh
    #ms-vscode.makefile-tools
    #ms-vsliveshare.vsliveshare
    #ms-python.python
    #mechatroner.rainbow-csv
  ];
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
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # wayland support for vscode in particular
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    anki-bin
    evince
    calibre
    wget
    nautilus
    (import ../update-git.nix {inherit pkgs;})
    xwayland-satellite
  ];

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
  };

  # fonts
  fonts = {
    enableDefaultPackages = true; # optional: includes common fonts
    packages = with pkgs; [
      dejavu_fonts
    ];
  };
}
