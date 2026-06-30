{ self, ... }: let
  vars = builtins.fromJSON (builtins.readFile ./cluster-vars.json);
  controlPlane = builtins.head (builtins.filter (s: s.role == "control-plane") vars.servers);
in {
  flake.nixosModules.kubernetes-server = { pkgs, ... }: {
    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        "--disable=traefik"
        "--tls-san ${controlPlane.ip}"
        "--tls-san ${controlPlane.tailscaleIp}" # Trust the VPN IP
        "--node-ip ${controlPlane.tailscaleIp}" # Bind to VPN
        "--flannel-iface tailscale0" # Route pod traffic via VPN
      ];
    };

    networking.firewall.allowedTCPPorts = [80 443 6443 10250];
    networking.firewall.allowedUDPPorts = [8472];

    environment.systemPackages = with pkgs; [
      k3s
    ];
  };
}
