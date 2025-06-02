{config, ...}:
{
    programs.niri.settings = {

      outputs = {
          "eDP-1" = {
            mode.width = 2880;
            mode.height = 1800;
            mode.refresh = 60.001;
            position.x = 0;
            position.y = 0;
          };
        };

    };
}

# niri msg outputs
# Output "California Institute of Technology 0x1416 Unknown" (eDP-1)
#   Current mode: 2880x1800 @ 60.001 Hz (preferred)
#   Variable refresh rate: supported, disabled
#   Physical size: 300x190 mm
#   Logical position: 0, 0
#   Logical size: 1645x1028
#   Scale: 1.75
#   Transform: normal
#   Available modes:
#     2880x1800@60.001 (current, preferred)
#     2880x1800@120.000
#     1920x1200@60.001
#     1920x1080@60.001
#     1600x1200@60.001
#     1680x1050@60.001
#     1280x1024@60.001
#     1440x900@60.001
#     1280x800@60.001
#     1280x720@60.001
#     1024x768@60.001
#     800x600@60.001
#     640x480@60.001