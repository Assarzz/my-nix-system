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
            rustup
          ];
        }
      )

      # Rust
      (
        { pkgs, ... }:
        {
          # It adds this toolchain i have specified declaratively
          # in the /home/assar/.rustup directory. Which is my "rustup home" as seen by `rustup show`
          # Interestingly any other toolchain installed, even automatically via a rust-toolchain.toml in a nix-shell, is added in this "rustup home" aswell.
          # Therfore they are not deleted when you go out of the shell or run `nix store gc`
          
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
