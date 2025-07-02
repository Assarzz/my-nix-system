{inputs, pkgs, ...}:
{
  imports = [
    inputs.niri.nixosModules.niri
  ];
  # nix.settings = {
  #   substituters = ["https://cache.nixos.org" "https://niri.cachix.org"];
  #   trusted-public-keys = [
  #   "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  #   "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
  #   ];
  # };

  programs.niri.enable = true;
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];
  programs.niri.package = pkgs.niri-unstable;

}



# moved