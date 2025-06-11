{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    ags.url = "github:Aylur/ags";
    ags.inputs.nixpkgs.follows = "nixpkgs";
    
    custom-neovim.url = "./neovim";
    custom-neovim.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, niri,  ... }@inputs: let 

    system = "x86_64-linux";
    #pkgs = nixpkgs.legacyPackages.${system};
    mkSystem = host: nixpkgs.lib.nixosSystem {
      inherit system;
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
            extraSpecialArgs = { inherit inputs; }; # Way to pass inputs to Home Manager user modules
            users.assar.imports = [
              ./hosts/${host}/home.nix
              ./homeManagerModules
              inputs.ags.homeManagerModules.default # you need to do this here and not inside the default homemanager module so it does not become circular, because inside this function inputs its guranteed to be completed
              ];
          };
        }
      ];
    }; 
  in {
    
    nixosConfigurations = {
      vm1 = mkSystem "vm1";
      pioneer256 = mkSystem "pioneer256";
      igniter = mkSystem "igniter";
      strategist = mkSystem "strategist";
    };
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
