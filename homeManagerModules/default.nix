{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  ssh-keyname = "id_ed25519";
in
{

  imports = [
    ./niri.nix
    ./theme.nix
    ./ags.nix
  ];

  stylix.targets.vscode.enable = false;
  stylix.targets.niri.enable = false;

  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  home = {
    packages = with pkgs; [
      hello
    ];
    username = "assar";
    homeDirectory = "/home/assar";
    stateVersion = "25.05";

    activation = {
      generate-ssh-keys = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" ] ''
        if [ ! -f "$HOME/.ssh/${ssh-keyname}" ]; then
          mkdir -p $HOME/.ssh
          ${pkgs.openssh}/bin/ssh-keygen -f $HOME/.ssh/${ssh-keyname} -N ""
        fi
      '';
      # generate-ssh-keys= lib.hm.dag.entryAfter ["myActivationAction1"] ''
      # <command1>
      # '';
    };
  };

  services.mako.enable = true;
  programs = {
    git = {
      enable = true;
      # Set your personal information.
      userName = "Assarzz";
      userEmail = "assarlannerbornzz@gmail.com";
    };
    ssh = {
      enable = true;
      #addKeysToAgent
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
    helix = {
      enable = true;
      package = inputs.helix.packages.${pkgs.system}.default;
      extraConfig = ''
        [editor.lsp]
        display-messages = true
      '';
      settings = {

        # these dont overwrite they add to whatever is in extraConfig
        keys = {
          normal = {
            H = ":buffer-previous";
            L = ":buffer-next";
            space = {
              "." = ":fmt";
            };
            C-g = [
              # Lazygit
              ":write-all"
              ":new"
              ":insert-output lazygit"
              ":buffer-close!"
              ":redraw"
              ":reload-all"
            ];
            C-y = [
              # Yazi
              ":sh rm -f /tmp/unique-file"
              ":insert-output yazi %{buffer_name} --chooser-file=/tmp/unique-file"
              ":insert-output echo '\x1b[?1049h\x1b[?2004h' > /dev/tty"
              ":open %sh{cat /tmp/unique-file}"
              ":redraw"
            ];
            space = {
              e = [
                # Yazi
                ":sh rm -f /tmp/unique-file-h21a434"
                ":insert-output yazi '%{buffer_name}' --chooser-file=/tmp/unique-file-h21a434"
                ":insert-output echo \"x1b[?1049h\" > /dev/tty"
                ":open %sh{cat /tmp/unique-file-h21a434}"
                ":redraw"
              ];
              E = [
                # Yazi
                ":sh rm -f /tmp/unique-file-u41ae14"
                ":insert-output yazi '%{workspace_directory}' --chooser-file=/tmp/unique-file-u41ae14"
                ":insert-output echo \"x1b[?1049h\" > /dev/tty"
                ":open %sh{cat /tmp/unique-file-u41ae14}"
                ":redraw"
              ];
            };
          };
        };
      };
      extraPackages = with pkgs; [
        clippy
        rustfmt
        wl-clipboard
        yazi
      ];
      languages = {
        language-server.typescript-language-server = with pkgs.nodePackages; {
          command = "${typescript-language-server}/bin/typescript-language-server";
          # args = [
          #   "--stdio"
          #   "--tsserver-path=${typescript}/lib/node_modules/typescript/lib"
          # ];
        };
        language-server.rust-analyzer = {
          command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
          config = {
            check.command = "clippy";
            cargo.features = "all";
          };
        };

        language-server.nil = {
          command = "${pkgs.nil}/bin/nil";
        };
        language = [
          {
            name = "rust";
            #auto-format = false;
          }
        ];
      };
    };
    alacritty.enable = true;
    fuzzel.enable = true;
    yazi = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
