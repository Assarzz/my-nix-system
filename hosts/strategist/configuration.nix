{ config, lib, pkgs, ... }:

{

  #steam.enable = true;
  nas.client.enable = true;
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
    system.stateVersion = "24.11"; # Did you read the comment?

}