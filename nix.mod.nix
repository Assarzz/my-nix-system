{
  universal.modules = [
    {
      nixpkgs.config.allowUnfree = true;
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      system.stateVersion = "24.11"; # Did you read the comment? No

    }
  ];


  # I didn't know where to put this, its kinda related to nix itself.
  igniter.system = "x86_64-linux";
  pioneer.system = "x86_64-linux";
  strategist.system = "x86_64-linux";
  insomniac.system = "x86_64-linux";
}
