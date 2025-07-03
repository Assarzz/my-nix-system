{helix, ...}:{
  universal.modules = [
    {
      environment.variables.EDITOR = "hx";

    }
  ];
  universal.home_modules = [
    ({pkgs, ...}:{
      programs.helix = {
        enable = true;
        package = helix.packages.${pkgs.system}.default;
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
    })
  ];
}
