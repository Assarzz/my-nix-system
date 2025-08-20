# I count an app as something that is used by itself occasionally, not dependencies.
{ags, ...}:{
  universal.modules = [
    (
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          wget
          dua
          glances
        ];
      }
    )
  ];
    personal.modules = [
    (
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          calibre
          keepassxc
          element-desktop
          pavucontrol
          chromium
          anki
          ags.packages.x86_64-linux.ags # to get access to the ags cli in the PATH
          masterpdfeditor
          kdePackages.okular
          kdePackages.kdenlive
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

  personal.home_modules = [
    ({pkgs, ...}:{
      programs = {
        firefox.enable = true;
        alacritty.enable = true;
        fuzzel.enable = true;
      };
    })
  ];
}
