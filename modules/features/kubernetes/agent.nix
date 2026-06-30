{ self, ... }: let
  vars = builtins.fromJSON (builtins.readFile ./cluster-vars.json);
  controlPlane = builtins.head (builtins.filter (s: s.role == "control-plane") vars.servers);
in {
  flake.nixosModules.kubernetes-agent = { pkgs, ... }: {
    services.k3s = {
      enable = true;
      role = "agent";
      serverAddr = "https://${controlPlane.ip}:6443";
      tokenFile = "/var/lib/rancher/k3s/cluster-token";
      extraFlags = toString [
        "--flannel-iface tailscale0"
      ];
    };

    networking.firewall.allowedTCPPorts = [10250];
    networking.firewall.allowedUDPPorts = [8472];

    environment.systemPackages = with pkgs; [k3s];
  };
}
