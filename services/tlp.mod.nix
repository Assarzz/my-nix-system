{
  strategist.modules = [
    (
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          tlp # do i even need this when i have enabled tlp in home-manager? TODO check this. Either way it gives me the tlp binary in PATHS.
        ];
        services.tlp.enable = true;
      }
    )
  ];

}
