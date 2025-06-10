{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.jpInput = lib.mkEnableOption "jp input";

  config = lib.mkIf config.jpInput {

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };

  };

}
