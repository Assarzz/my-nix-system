# I count an app as something that is used by itself, not as a dependency, occasionally.
{
  universal.modules = [
    (
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          evince
          calibre
          (import ../update-git.nix { inherit pkgs; })
          keepassxc
          dua
          glances
          element-desktop
          pavucontrol
          chromium
          wget
          anki
        ];
      }
    )

    (
      { pkgs, ... }:
      {
        # Gnome files.
        environment.systemPackages = with pkgs; [

          nautilus
          # Particularily to get gnome files to recognize USB devices (1)
          usbutils # Tools for working with USB devices, such as lsusb
          udiskie # Removable disk automounter for udisks
          udisks # Daemon, tools and libraries to access and manipulate disks, storage devices and technologies
        ];
        # particulariy to be able to unzip files in gnome files
        programs.file-roller.enable = true;
      }
    )
  ];

  universal.home_modules = [
    {
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
    }

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
