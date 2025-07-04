{
  universal.modules = [

    {
      virtualisation.docker = {
        # Disabling the system wide Docker daemon.
        enable = false;

        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };
    }
/*     (
      { config, pkgs, ... }:

      {
        config.virtualisation.oci-containers.containers = {
          hackagecompare = {
            image = "chrissound/hackagecomparestats-webserver:latest";
            ports = [ "127.0.0.1:3010:3010" ];
            volumes = [
              "/root/hackagecompare/packageStatistics.json:/root/hackagecompare/packageStatistics.json"
            ];
            cmd = [
              "--base-url"
              "\"/hackagecompare\""
            ];
          };
        };
      }
    ) */
  ];
}
