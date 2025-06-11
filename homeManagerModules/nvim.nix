{ inputs, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      gruvbox-nvim
    ];
  };
  home.file.".config/nvim" = {
    source = inputs.self.outPath + "/nvim"; # This path is relative to your home.nix
    recursive = true; # Important for linking subdirectories and files
  };
}
