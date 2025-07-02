{
  strategist.moduels = [
    (
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          tlp
        ];
      }
    )
  ];
}
