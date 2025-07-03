{

  universal.modules = [
    {
      networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
      services = {
        openssh = {
          enable = true;
          settings.PermitRootLogin = "yes";
        };
        tlp.enable = true;
        upower.enable = true; # as far as i know this should only enable the upower d-bus service so other apps can interact with it, only add not destroy
      };
    }
  ];
  universal.home_modules = [
    {
      services = {
        mako.enable = true;
      };
    }
  ];
}
