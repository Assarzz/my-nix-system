{ags_system, ...}:{
  personal.modules = [
    {
      services.upower.enable = true; # As far as i know this should only enable the upower d-bus service so other apps can interact with it, only add not destroy.
    }
  ];

  personal.home_modules = [
    {
      programs.niri.settings.spawn-at-startup = [
        { command = [ "${ags_system.packages.x86_64-linux.default}/bin/my-shell" ]; }
      ];
    }
  ];
}
