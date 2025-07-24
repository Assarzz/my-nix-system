{           
  personal.modules = [
    (
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          elan
          gcc
          nixfmt-rfc-style # formatter for nix
        ];
      }
    )
  ];
}
