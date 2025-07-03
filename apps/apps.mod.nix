# I count an app as something that is used by itself, not as a dependency, occasionally.
{ags, ...}:{
  universal.modules = [
    (
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          evince
          calibre
          keepassxc
          dua
          glances
          element-desktop
          pavucontrol
          chromium
          wget
          anki
          ags.packages.x86_64-linux.ags # to get access to the ags cli in the PATH
        ];
      }
    )
  ];

  universal.home_modules = [
    ({pkgs, ...}:{
      programs = {
        git = {
          enable = true;
          # Set your personal information.
          userName = "Assarzz";
          userEmail = "assarlannerbornzz@gmail.com";
        };
        ssh = {
          enable = true;
        };
        firefox.enable = true;
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

        alacritty.enable = true;
        fuzzel.enable = true;

      };
    })

    # For yazi
    {
      programs = {
        yazi = {
          enable = true;
          enableBashIntegration = true;
        };
        bash = {
          enable = true;
          # ... other bash configuration
          initExtra = ''
            function y() {
              local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
              yazi "$@" --cwd-file="$tmp"
              local cwd="$(cat "$tmp")"
              rm -f "$tmp"
              if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                builtin cd "$cwd"
              fi
            }
          '';
        };
      };
    }
  ];
}
