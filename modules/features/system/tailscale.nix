{...}: {
  flake.nixosModules.tailscale = {...}: {
    services.tailscale = {
      enable = true;
      # Lets the nyx Tailnet panel go up/down and switch exit nodes without sudo.
      extraSetFlags = [ "--operator=chris" ];
    };
    networking.firewall = {
      checkReversePath = false;
      trustedInterfaces = ["tailscale0"];
      allowedUDPPortRanges = [
        {
          from = 50000;
          to = 65535;
        }
      ];
    };
  };
}
