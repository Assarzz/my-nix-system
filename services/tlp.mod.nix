{
  strategist.modules = [
    (
      { pkgs, ... }:
      {
        services.tlp.enable = true;
      }
    )
  ];

}
