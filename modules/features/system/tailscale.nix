{...}: {
  flake.nixosModules.tailscale = {...}: {
    services.tailscale.enable = true;
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
