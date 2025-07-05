{

  universal.modules = [
    {
      networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
      services = {
        openssh = {
          enable = true;
        };
      };
    }
  ];
  personal.home_modules = [
    {
      services = {
        mako.enable = true;
      };
    }
  ];
}
