{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    niri.url = "github:sodiboo/niri-flake";
    ags.url = "github:Aylur/ags";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, niri, ... }@inputs: let 
    mkSystem = host: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [ 
        ./hosts/${host}/configuration.nix 
        ./nixosModules
        home-manager.nixosModules.home-manager
        {
          networking.hostName = host;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.assar.imports = [./hosts/${host}/home.nix ./homeManagerModules];
          };
        }
      ];
    }; 
  in {
    nixosConfigurations = {
      vm1 = mkSystem "vm1";
      # make hostname vm1 etc
    };
    #homeManagerModules.default = ./homeManagerModules; 
  };
  nixConfig = {
  extra-substituters = [
    "https://nix-community.cachix.org"
    "https://niri.cachix.org"
  ];
  extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
  ];
};
}
