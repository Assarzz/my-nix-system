{ stylix, ... }:
{

  personal.modules = [
    stylix.nixosModules.stylix

    (
      { pkgs, config, ... }:
      {

        stylix.enable = true;
        # https://tinted-theming.github.io/tinted-gallery/
        stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark.yaml";

        stylix.fonts.monospace.package = pkgs.nerd-fonts.fira-code;
        stylix.fonts.monospace.name = "FiraCode Nerd Font";

        stylix.fonts.sansSerif.package = pkgs.nerd-fonts.ubuntu;
        stylix.fonts.sansSerif.name = "Ubuntu Nerd Font";

        stylix.fonts.serif = config.stylix.fonts.sansSerif;

        #stylix.fonts.sizes.applications = 10;
        #stylix.fonts.sizes.desktop = 12;

      }
    )

    (
      { pkgs, ... }:
      {
        # fonts
        fonts.packages = with pkgs; [
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-emoji
          liberation_ttf
          fira-code
          fira-code-symbols
          mplus-outline-fonts.githubRelease
          dina-font
          proggyfonts
        ];
      }
    )
  ];
  personal.home_modules = [
    {
      stylix.targets.vscode.enable = false;
      stylix.targets.niri.enable = false;
    }
  ];
}
