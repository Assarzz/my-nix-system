{config, ...}:
{
    programs.niri.settings = {
        input.keyboard.xkb.layout = "se";

        layout = {
            default-column-width = { proportion = 1.0; };

        };
        binds = with config.lib.niri.actions; {
            "Mod+T".action = spawn "alacritty";
            "Mod+D".action = spawn "fuzzel";
            "Mod+Q".action =  close-window;
            "Mod+Left".action = focus-column-left;
            "Mod+Right".action = focus-column-right;

        };
    };
}