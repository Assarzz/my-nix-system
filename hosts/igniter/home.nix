{config, ...}:
{
    programs.niri.settings = {

      outputs = {
/*           "HDMI-A-1" = {
            enable = false;
            mode.width = 3840;
            mode.height = 2160;
            mode.refresh = 60.0;
            position.x = 0;
            position.y = -cfg."HDMI-A-1".mode.height;
          }; */
          "DP-1" = {
            #     2560x1440@164.802
            mode.width = 2560;
            mode.height = 1440;
            mode.refresh = 164.802;
            position.x = 0;
            position.y = 0;
          };
        };

    };
}