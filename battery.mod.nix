{
  strategist.modules = [
    (
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          tlp # do i even need this when i have enabled tlp in home-manager? TODO check this
        ];

      }
    )
  ];
}
