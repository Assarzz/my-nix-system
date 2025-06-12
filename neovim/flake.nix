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
                  languages.rust.enable = true;
                  languages.ts.enable = true;
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


                };
              }
            ];
          }).neovim;
      };
    };
}
