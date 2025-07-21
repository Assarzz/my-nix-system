{           
  personal.modules = [
    (
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          elan
          rustup
          nixfmt-rfc-style # formatter for nix
        ];
        
      }
    )
  ];
}
