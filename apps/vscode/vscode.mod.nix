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

    {
      # Allow using qtwebengine-5.15.19 despite it being insecure. It is used by vscode python extension.
      nixpkgs.config.permittedInsecurePackages = [
        "qtwebengine-5.15.19"
      ];
    }

  ];
  personal.home_modules = [

    # vs-code
    (
      {
        pkgs,
        lib,
        config,
        ...
      }:
      let
        # gets the path of the root directory, /etc/nixos in my case.

        PROJECT_ROOT = "/etc/nixos";
        mkSymlink = f: config.lib.file.mkOutOfStoreSymlink "${PROJECT_ROOT}/apps/vscode/${f}";

        settingsJSON = mkSymlink "settings.json";
        keybindingsJSON = mkSymlink "keybindings.json";
        snippetsDir = mkSymlink "snippets";

        # I had weird experience with some extensions not loading when i had home-manger config, and giving errors. Running a total flake update and rebuilding fixed it.
        extensions = [

          pkgs.nix-vscode-extensions.vscode-marketplace.rubymaniac.vscode-direnv

          pkgs.nix-vscode-extensions.vscode-marketplace.leanprover.lean4

          pkgs.vscode-extensions.streetsidesoftware.code-spell-checker

          pkgs.vscode-extensions.jnoortheen.nix-ide

          pkgs.vscode-extensions.rust-lang.rust-analyzer
          pkgs.nix-vscode-extensions.vscode-marketplace.tamasfe.even-better-toml
          pkgs.vscode-extensions.sumneko.lua
          
          # default jedi was garbage
          pkgs.vscode-extensions.ms-python.vscode-pylance
          pkgs.nix-vscode-extensions.vscode-marketplace.ms-python.python
          #pkgs.vscode-extensions.ms-python.python

          pkgs.vscode-extensions.ms-vscode.cpptools # c/c++ extension
        ];
      in
      {
        programs.vscode = {
          profiles.default.extensions = extensions;
          enable = true;
        };
        # Note that the path ~/.config/ is prepended for the symlink paths.
        xdg.configFile = {
          "Code/User/keybindings.json".source = keybindingsJSON;
          "Code/User/settings.json".source = settingsJSON;
          "Code/User/snippets".source = snippetsDir;
        };
        # This sets the default application for opening plain text files to vs code
        xdg.mimeApps.defaultApplications."text/plain" = "code.desktop";

      }
    )

    # direnv
    (
      { pkgs, ... }:
      {
        programs.direnv.enable = true;
        programs.direnv.nix-direnv.enable = true;
        home.packages = [ pkgs.direnv ];
      }
    )
  ];
}
