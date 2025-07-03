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
}
