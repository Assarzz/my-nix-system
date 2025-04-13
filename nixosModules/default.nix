{ config, lib, pkgs, ... }:
{
  imports = [
    ./users.nix
    #./graphics.nix
    ./niri.nix
  ];

}
