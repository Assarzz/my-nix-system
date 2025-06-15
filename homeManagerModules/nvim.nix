{inputs, ...}:
{
    imports = [
    # ADD THIS IMPORT:
    # It points to the 'homeModule' output from your nvim flake
    inputs.my-neovim.homeModules.default
  ];
    nvim = {
        enable = true;
        # go back to this when we have made enough changes to be able to tell difference beween default and my nvim
        #package = inputs.my-neovim.packages.default;
  };
}