{ nix-vscode-extensions, ... }:
{

  personal.modules = [
    
    # nix-ide
    (
      { pkgs, ... }:
      {
        nixpkgs.overlays = [ nix-vscode-extensions.overlays.default ];
        # now how do i get access to them?

        environment.systemPackages = with pkgs; [
          nixfmt-rfc-style # formatter for nix required to be in path by nix-ide vscode extension
          nixd # nix language server required to be in path by nix-ide
        ];

      }
    )

  ];
  personal.home_modules = [
    (
      { pkgs, ... }:
      {
        programs = {

          # I had weird experience with some extensions not loading, and giving errors. Running a total flake update and rebuilding fixed it.
          vscode = {
            enable = true;
            
            # presumably i will not to manually update this file in the future whenever i add extensions :/
            # Needed because nix-ide does not automatically configure lsp support
            #profiles.userSettingsuserSettings = ./settings.json; 
            extensions = [

              pkgs.nix-vscode-extensions.vscode-marketplace.rubymaniac.vscode-direnv

              pkgs.nix-vscode-extensions.vscode-marketplace.leanprover.lean4

              pkgs.vscode-extensions.streetsidesoftware.code-spell-checker

              pkgs.vscode-extensions.jnoortheen.nix-ide

              pkgs.vscode-extensions.rust-lang.rust-analyzer
              pkgs.nix-vscode-extensions.vscode-marketplace.tamasfe.even-better-toml
              pkgs.vscode-extensions.sumneko.lua
              # default jedi was garbage
              # pkgs.vscode-extensions.ms-python.vscode-pylance
              #pkgs.vscode-extensions.ms-python.python
              #pkgs.nix-vscode-extensions.vscode-marketplace.ms-python.python
            ];
          };
        };
      }
    )

    # direnv
    ({pkgs, ...}:{
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
      home.packages = [ pkgs.direnv ];
    })
  ];
}
