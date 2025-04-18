{ config, lib, pkgs, ... }:
{
  imports = [
    ./users.nix
    #./graphics.nix
    ./niri.nix
  ];
  nixpkgs.config.allowUnfree = true;

  # wayland support for vscode in particular
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    anki-bin
    evince
    calibre
  ];
}
