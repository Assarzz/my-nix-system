{ nix-vscode-extensions, ... }:
{

  personal.modules = [
    {
      nixpkgs.overlays = [ nix-vscode-extensions.overlays.default ];
      # now how do i get access to them?

    }
  ];
  personal.home_modules = [
    (
      { pkgs, ... }:
      {
        programs = {

          # I had weird experience with some extensions not loading, and giving errors. Running a total flake update and rebuilding fixed it.
          vscode = {
            enable = true;
            extensions = [

              pkgs.nix-vscode-extensions.vscode-marketplace.leanprover.lean4

              pkgs.vscode-extensions.streetsidesoftware.code-spell-checker

              pkgs.vscode-extensions.jnoortheen.nix-ide

              pkgs.vscode-extensions.rust-lang.rust-analyzer
              pkgs.nix-vscode-extensions.vscode-marketplace.tamasfe.even-better-toml
              pkgs.vscode-extensions.sumneko.lua
              # default jedi was garbage
              pkgs.vscode-extensions.ms-python.vscode-pylance

            ];
          };
        };
      }
    )
  ];
}
