{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      packages.x86_64-linux = {
        # Set the default package to the wrapped instance of Neovim.
        # This will allow running your Neovim configuration with
        # `nix run` and in addition, sharing your configuration with
        # other users in case your repository is public.
        default =
          (inputs.nvf.lib.neovimConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              {
                config.vim = {
                  # Enable custom theming options
                  #theme.enable = true;

                  # Enable Treesitter
                  treesitter.enable = true;

                  # Other options will go here. Refer to the config
                  # reference in Appendix B of the nvf manual.
                  # ...
                  theme.enable = true;
                  theme.name = "gruvbox";
                  theme.style = "dark";

                  languages.nix.enable = true;
                  languages.nix.format.enable = true;
                  languages.nix.lsp.enable = true;

                  languages.rust.enable = true;

                  # javascript and typescript
                  languages.ts.enable = true;
                  # languages.ts.extraDiagnostics.enable = true;
                  languages.ts.lsp.enable = true;
                  languages.ts.lsp.server = "denols";

                  languages.python.enable = true;
                  languages.markdown.enable = true;
                  languages.html.enable = true;

                  telescope.enable = true;
                  telescope.setupOpts = {
                    pickers.buffers.initial_mode = "normal";
                  };
                  options.tabstop = 4;
                  options.expandtab = true;
                  options.softtabstop = 4;
                  options.shiftwidth = 4;
                  #options.clipboard = "unnamedplus";

                  # fix neovim clipboard problem
                  clipboard.enable = true;
                  clipboard.providers.wl-copy.enable = true;
                  clipboard.registers = "unnamedplus";

                  keymaps = [
                    {
                      key = "<";
                      mode = "v";
                      silent = true;
                      action = "<gv";
                    }
                    {
                      key = ">";
                      mode = "v";
                      silent = true;
                      action = ">gv";
                    }
                    {
                      key = "-";
                      mode = "n";
                      silent = true;
                      action = ":Oil<CR>";
                    }
                  ];
                    autopairs.nvim-autopairs.enable = true; 
                    utility.oil-nvim.enable = true;
                    #binds.whichKey.enable = true;
                    #binds.hardtime-nvim.enable = true;
                    utility.motion.flash-nvim.enable = true;
                    #filetree.neo-tree.enable = true;

                    ui.colorizer.enable = true; # code that sets color, the code itself will be that color

                    autocomplete.nvim-cmp.enable = true;
                };
              }
            ];
          }).neovim;
      };
    };
}






