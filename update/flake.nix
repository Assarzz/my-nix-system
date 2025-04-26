{
  description = "Flake to auto-commit & push via writeShellScriptBin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";    # ← adjust to your platform
    pkgs   = nixpkgs.legacyPackages.${system};

    updateScript = pkgs.writeShellScriptBin "update-git" ''
      #!${pkgs.bash}/bin/bash
      git add .
      git commit -m "update"
      git push
    '';
  in {
    # `nix run` will invoke this script
    apps.${system}.default = {
      type    = "app";
      program = "${updateScript}";
      # make sure git is in the PATH at runtime
      deps    = [ pkgs.git ];
    };
  };
}
