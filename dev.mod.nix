(
  { rust-overlay, ... }:
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

      # Rust
      (
        { pkgs, ... }:
        {
          nixpkgs.overlays = [ rust-overlay.overlays.default ];

          environment.systemPackages = [
            (pkgs.rust-bin.stable.latest.default.override {
              extensions = [
                "rust-src"
                "rust-analyzer"
              ];
            })
          ];
        }
      )
    ];
  }
)
