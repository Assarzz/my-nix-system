{
  description = "Simple flake to auto-commit & push";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";  # or your platform, e.g. "aarch64-linux"
      pkgs   = nixpkgs.legacyPackages.${system};
    in {
      # `nix run .` will invoke this
      apps.${system}.default = {
        type = "app";
        program = "${pkgs.stdenv}/bin/sh";
        args = [
          "-c"
          ''
            git add . &&
            git commit -m "update" &&
            git push
          ''
        ];
        # ensure git is in the PATH at runtime
        deps = [ pkgs.git ];
      };
    };
}
