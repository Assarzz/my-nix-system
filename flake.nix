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

/*     helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs"; */

    ags_system.url = "github:Assarzz/ags_overlay";
    ags_system.inputs.nixpkgs.follows = "nixpkgs";
    ags_system.inputs.ags.follows = "ags";

    lean.url = "github:lenianiva/lean4-nix";
    lean.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

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
      # match: attrSet -> string -> attrSet. Gets the attribute with name
      match = flip getAttr;

      # dir0 -> {a.mod.nix = dir0/a.mod.nix; b.mod.nix = dir0/b.mod.nix; dir1/c.mod.nix = dir0/dir1/c.mod.nix;}
      # important, only files are included in the final set, not empty folders
      # self is passed which gets evaluated to the this flakes location in the nix store
      read_dir_recursively =
        dir:
        let
          # name -> {name = dir/name; } or name -> {name = dir/name; }. Returns the value of either attribute (1) or (2)
          name_to_dir_slash_name = (
            this: # some file or directory name, not some absolute path

            # string -> attrSet
            match {

              # (1) directory = {name = "${this}/${subpath}"; value =  }
              directory =
                let
                  # returns (subpath: value: {name = "${this}/${subpath}"; value = value;})
                  subPathAndValueToSubPath2AndValue = (subpath: nameValuePair "${this}/${subpath}");
                in
                mapAttrs' subPathAndValueToSubPath2AndValue (read_dir_recursively "${dir}/${this}");
              # (2)
              regular = {
                ${this} = "${dir}/${this}";
              };
              symlink = { };
            }
          );
        in
        concatMapAttrs name_to_dir_slash_name (builtins.readDir dir); # {a.mod.nix = "regular"; b = "directory"; c.mod.nix = "regular"; }

      # {self, nixpkgs, configs, machines, merge, extras}
      # what happens when params gets evaluated? if we believe in thunks and the arcane art of making every attribute in a set its own thunk this apparantly works.
      # because then evaluating params does not mean evaluating raw_configs (this would cause infinite recursion i think)
      # but that means surely we cant evaluate params.configs
      params = inputs // {
        configs = raw_configs;
        lib = nixpkgs.lib;
        machines = {
          strategist = { };
          pioneer = { };
          igniter = { };
          vm1 = { };
          insomniac = { };
        };
        # no parethesis means it looks for these in the outside scope and adds them both to the attrSet. its not calling a function
        inherit merge;
      };

      # Function that takes the flake itself to pipe through all the below functions.
      # It is converted to the absolute store path, the root directory, automatically.
      # after this we have all the values in the attrS be finished module attribute sets (the function has been called)
      read_all_modules = flip pipe [
        read_dir_recursively

        # (const (hasSuffix ".mod.nix")) :: Any -> (String -> Bool)
        # basically we only have those paths with .mod.nix left in the attrSet
        (filterAttrs (flip (const (hasSuffix ".mod.nix"))))

        # (const import) :: Any -> (path -> attrSet)
        # "test.mod.nix" :: Any, "/nix/store/nw...ce/test.mod.nix" :: path
        # resulting in {"test.mod.nix" = <imported expression>; ...}
        (mapAttrs (const import))

        # Shenanigans is done which results in the piped attribute is either turned in to a function or already is a function, and then params is passed giving us the finished modules.
        # The core lies in the fact that toFunction acts differently depending on if input already is function or not. Coming up with this is insane.
        (mapAttrs (const (flip toFunction params)))
      ];
      # input can be something like universal.
      #{ modules = [ a ]; system = "1";} : {modules = [ b ]; system = "2";} : {modules = [ a b ]; home_modules = []; system = "1";}
      merge =
        prev: this:
        {
          # if there exists prev.modules take that otherwise empty module list
          modules = prev.modules or [ ] ++ this.modules or [ ];
          home_modules = prev.home_modules or [ ] ++ this.home_modules or [ ];
        }
        # if this or prev has system attribute incldue it
        // (optionalAttrs (prev ? system || this ? system) {
          system = prev.system or this.system;
        });

      # list of the nix expressions from every n.mod.nix module with function already called
      # [ ... { universal = { modules = [ { boot = { loader = { efi = { canTouchEfiVariables = true; }; systemd-boot = { enable = true; }; }; }; } ]; }; }      all_modules = attrValues (read_all_modules "${self}"); ... ]
      all_modules = attrValues (read_all_modules "${self}");

      # builtins.foldl' :: (a -> b -> a) -> a -> [b] -> a
      # builtins.foldl' merge { } :: [b] -> a
      flat_merge = builtins.foldl' merge { };

      # mergeAttrsList means normal merge.
      # We specify a function that decides what to happen when two sets have the same attribute, like personal.
      # machine is something like personal
      # for zipAttrsWith we specify how given the attribute name and a list of all the attribute values that share that name what the attribute value for that name will be in the final attribute set
      # We dont want the result to be [ [mod1 mod2] [mod3 mod4]], we want [mod1 mod2 mod3 mod4]
      # result {personal = {modules = [mod1 mod2 mod3 mod4]; system = "x86_64-linux"; home_modules = [] }; somebody = {...}}
      raw_configs = builtins.zipAttrsWith (const flat_merge) all_modules;

      # Change the values from normal attrSets to nixosSystem attrSets.
      # nixosSystem expects {system = ""; modules = [ mod1 mod2 ];}
      configs = builtins.mapAttrs (const (
        config:
        nixpkgs.lib.nixosSystem {
          inherit (config) system;
          modules = config.modules ++ [
            # Special module added to give access to home_modules inside the nixos module that sets up home-manager
            # Modules defined here have special privlages in that they can access inputs without going via specialArgs, it feel like magic.
            # Basically we utalize that config gives access to anything defined in a module.
            # could you not just have done magic.home_modules = config.home_modules; by this same logic??
            # the usage in relevent module seems to confirm this theory: "_module.args.home_modules = config.home_modules;"
            # Instead of just going directly via "home_modules" that should be provided as an module input.
            # TODO check this out!
            {
              _module.args.home_modules = config.home_modules;

            }
          ];
        }
      )) raw_configs;

    in
    {

      # change values of the params.machines attrSet to corresponding one from configs attrSet
      # we only use one of the nixosConfigurations outputs for any machine like strategist
      nixosConfigurations = builtins.mapAttrs (name: const configs.${name}) params.machines;
    };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
      "https://lean4.cachix.org/"
      "https://cache.garnix.io"
      #"https://helix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "lean4.cachix.org-1:mawtxSxcaiWE24xCXXgh3qnvlTkyU7evRRnGeAhD4Wk="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      #"helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];
  };
}
