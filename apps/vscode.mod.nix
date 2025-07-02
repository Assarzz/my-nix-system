{
  universal.home_modules = [
    (
      { pkgs, ... }:
      {
        programs = {
          vscode = {
            enable = true;
            extensions = with pkgs.vscode-extensions; [
              rust-lang.rust-analyzer
              jnoortheen.nix-ide
              sumneko.lua
              # default jedi was garbage
              ms-python.vscode-pylance
            ];
          };
        };
      }
    )
  ];
}
