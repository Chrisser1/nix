{ self, ... }: 
let 
    vars = builtins.fromJSON (builtins.readFile ./cluster-vars.json);
in {
    flake.nixosModules.kubernetes-agent = { pkgs, ... }: {
        services.k3s = {
            enable = true;
            role = "agent";
            # The IP of my main Oracle Control Plane
            serverAddr = "https://${vars.controlPlaneIp}:6443"; 
            tokenFile = "/var/lib/rancher/k3s/cluster-token"; 
            extraFlags = toString [
                "--flannel-iface tailscale0"
            ];
        };

        # Agents only need ports for internal cluster communication
        networking.firewall.allowedTCPPorts = [ 10250 ]; # Kubelet
        networking.firewall.allowedUDPPorts = [ 8472 ];  # Flannel VXLAN network

        environment.systemPackages = with pkgs; [ k3s ];
    };
}