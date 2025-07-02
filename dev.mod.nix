{
  universal.moduels = [
    (
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          lean4
          cargo
          rustc
          nixfmt-rfc-style # formatter for nix
        ];
      }
    )
  ];
}
