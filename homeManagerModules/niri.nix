{config, ...}:
{
    programs.niri.settings = {
        input.keyboard.xkb.layout = "se";

        layout = {
            default-column-width = { proportion = 1.0; };
            gaps = 0;
            preset-column-widths = [
                { proportion = 1. / 3.; }
                { proportion = 1. / 2.; }
                { proportion = 2. / 3.; }
                #{ proportion = 1.0; }

                # { fixed = 1920; }
            ];
            focus-ring = {
              enable = false;
            #   width = 10000;
            #   active.color = "#00000055";
            };

        };
        binds = with config.lib.niri.actions; {
            "Mod+T".action = spawn "alacritty";
            "Mod+D".action = spawn "fuzzel";
            "Mod+Q".action =  close-window;

            "Mod+Left".action = focus-column-left;
            "Mod+Right".action = focus-column-right;
            "Mod+Down".action =  focus-window-down;
            "Mod+Up".action = focus-window-up;
            "Mod+H".action = focus-column-left;
            "Mod+L".action = focus-column-right;
            "Mod+J".action = focus-window-down;
            "Mod+K".action = focus-window-up;

            "Mod+Ctrl+Left".action =move-column-left;
            "Mod+Ctrl+Down".action = move-window-down;
            "Mod+Ctrl+Up".action = move-window-up;
            "Mod+Ctrl+Right".action = move-column-right;
            "Mod+Ctrl+H".action = move-column-left;
            "Mod+Ctrl+J".action = move-window-down;
            "Mod+Ctrl+K".action = move-window-up;
            "Mod+Ctrl+L".action = move-column-right;

            "Mod+F".action = maximize-column;
            "Mod+Shift+F".action = fullscreen-window;

            "Mod+R".action = switch-preset-column-width;
            "Mod+Shift+R".action = switch-preset-window-height;


            "Print".action = screenshot;
            "Ctrl+Print".action = screenshot-screen;
            "Alt+Print".action = screenshot-window;

            # Powers off the monitors. To turn them back on, do any input like
            # moving the mouse or pressing any other key.
            "Mod+Shift+P".action = power-off-monitors;

            # The quit action will show a confirmation dialog to avoid accidental exits.
            "Mod+Shift+E".action = quit;
        };
        # spawn-at-startup = [];
    };
}