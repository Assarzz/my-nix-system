# insomniac120 can't sleep because its always terrifed of a potential power spike pushing it over 120W.
{ config, lib, pkgs, ... }:

{

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
    system.stateVersion = "24.11"; # Did you read the comment?

}