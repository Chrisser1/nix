{ self, ... }:
let 
    vars = builtins.fromJSON (builtins.readFile ./cluster-vars.json);
in {
    flake.nixosModules.kubernetes-server = { pkgs, ... }: {
        services.k3s = {
            enable = true;
            role = "server";
            extraFlags = toString [
                "--disable=traefik"
                "--tls-san ${vars.controlPlaneIp}"
                "--tls-san ${vars.controlPlaneTailscaleIp}" # Trust the VPN IP
                "--node-ip ${vars.controlPlaneTailscaleIp}" # Bind to VPN
                "--flannel-iface tailscale0"                # Route pod traffic via VPN
            ];
        };

        networking.firewall.allowedTCPPorts = [ 80 443 6443 10250 ];
        networking.firewall.allowedUDPPorts = [ 8472 ];

        environment.systemPackages = with pkgs; [
            k3s
        ];
    };
}