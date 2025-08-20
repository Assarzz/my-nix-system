{
  personal.modules = [
    (
      { pkgs, ... }:
      {
        services.greetd.enable = true; # It is the daemon that communicates with PAM for authentication.
        services.greetd.settings = {

          # On the very first start of greetd we don't need to authenticate.
          initial_session = {
            command = "${pkgs.niri-unstable}/bin/niri-session";
            user = "assar";
          };
          default_session = {
            command = "${pkgs.greetd.greetd}/bin/agreety --cmd ${pkgs.niri-unstable}/bin/niri-session";
          };
        };

      }
    )
  ];
}
