{home-manager, ...}: {
  universal.modules = [
    home-manager.nixosModules.home-manager
    ({config, ...}: {

      # It seems that here are some global configuration for all users?
      home-manager.backupFileExtension = "bak"; # Something about preventing "collisions"?
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true; #"Whether to enable installation of user packages through the users.users.<name>.packages option."
      
      # And here is configuration for only me. And all imported modules are in that namespace, as in every line is prepended by home-manager.users.assar
      # This is unlike anything in nixos i have seen.
      home-manager.users.assar = {

        imports = config._module.args.home_modules;
      };
    })
  ];
}
