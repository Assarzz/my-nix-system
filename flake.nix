{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    ags.url = "github:Aylur/ags";
    ags.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

    ags_system.url = "github:Assarzz/ags_overlay";
    ags_system.inputs.nixpkgs.follows = "nixpkgs";
    ags_system.inputs.ags.follows = "ags";


  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      niri,
      stylix,
      ...
    }@inputs:
    with nixpkgs.lib;
    let

      # resluts in a function that given a string, if string is "regular" return "dir/name"
      # or if "directory" return
      match = flip getAttr; # match :: attrSet -> string -> attrSet. gets the attribute with name

      test =
        this: # this is the path of some file or directory
        match {

          # directory = {name = "${this}/${subpath}"; value =  }
          directory = mapAttrs' (subpath: nameValuePair "${this}/${subpath}") (
            read_dir_recursively "${dir}/${this}"
          );
          regular = {
            ${this} = "${dir}/${this}";
          };
          symlink = { };
        };
      read_dir_recursively =
        dir: # dir ->
        concatMapAttrs test (builtins.readDir dir); # {a.mod.nix = "regular"; b = "directory"; c.mod.nix = "regular"; }

      # `const` helper function is used extensively: the function is constant in regards to the name of the attribute.
      read_all_modules = flip pipe [
        read_dir_recursively
        (filterAttrs (flip (const (hasSuffix ".mod.nix"))))
        (mapAttrs (const import))
        (mapAttrs (const (flip toFunction params)))
      ];

      system = "x86_64-linux";
      mkSystem =
        host:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${host}/configuration.nix
            ./nixosModules
            stylix.nixosModules.stylix
            (
              { pkgs, config, ... }:
              {
                stylix.enable = true;
                # https://tinted-theming.github.io/tinted-gallery/
                stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark.yaml";

                stylix.fonts.monospace.package = pkgs.nerd-fonts.fira-code;
                stylix.fonts.monospace.name = "FiraCode Nerd Font";

                stylix.fonts.sansSerif.package = pkgs.nerd-fonts.ubuntu;
                stylix.fonts.sansSerif.name = "Ubuntu Nerd Font";

                stylix.fonts.serif = config.stylix.fonts.sansSerif;

                #stylix.fonts.sizes.applications = 10;
                #stylix.fonts.sizes.desktop = 12;
              }
            )
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
    in
    {

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
      "https://lean4.cachix.org/"

    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "lean4.cachix.org-1:mawtxSxcaiWE24xCXXgh3qnvlTkyU7evRRnGeAhD4Wk="
    ];
  };
}
