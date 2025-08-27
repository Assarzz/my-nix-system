{           
  personal.modules = [
    (
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          elan
          gcc
        ];
      }
    )
  ];
}
