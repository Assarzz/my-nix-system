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

  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.


  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
    tlp.enable = true;
    upower.enable = true; # as far as i know this should only enable the upower d-bus service so other apps can interact with it, only add not destroy
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
