{
  universal.modules = [

    {
      virtualisation.docker = {
        enable = true;
        # Set up resource limits
        daemon.settings = {
          experimental = true;
          default-address-pools = [
            {
              base = "172.30.0.0/16";
              size = 24;
            }
          ];
        };
      };
/* 
      virtualisation.oci-containers = {
        backend = "docker";
        containers = {
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
      }; */

    }

  ];
}
