{ self, ... }: 
let 
    vars = builtins.fromJSON (builtins.readFile ./cluster-vars.json);
in {
    flake.homeModules.kubernetes-client = { pkgs, ... }: {
        home.packages = with pkgs; [
            kubectl
            kubernetes-helm
            k9s

            (writeShellScriptBin "fetch-kubeconfig" ''
                set -e # Stop the script if any command fails

                echo "☁️  Fetching kubeconfig from Oracle Server..."
                mkdir -p ~/.kube
                scp oracle-server:/etc/rancher/k3s/k3s.yaml ~/.kube/config

                echo "🔒 Securing permissions..."
                chmod 600 ~/.kube/config

                echo "🌐 Patching IP address..."
                # Automatically replace localhost with your Oracle public IP
                sed -i "s/127.0.0.1/${vars.controlPlaneIp}/g" ~/.kube/config

                echo "✅ Kubeconfig successfully configured!"
                echo "🚀 Type 'k9s' to connect to your cluster."
            '')

            (writeShellScriptBin "bootstrap-node" ''
                set -e
                NEW_IP=$1
                NEW_USER=$2

                if [ -z "$NEW_IP" ] || [ -z "$NEW_USER" ]; then
                  echo "❌ Usage: bootstrap-node <new-server-ip> <ssh-user>"
                  echo "Example: bootstrap-node 192.168.1.50 root"
                  exit 1
                fi

                echo "☁️  Fetching Master Token from Control Plane (${vars.controlPlaneSshAlias})..."
                
                # We replaced 'oracle-server' with the dynamic alias!
                TOKEN=$(ssh ${vars.controlPlaneSshAlias} "sudo cat /var/lib/rancher/k3s/server/node-token")

                echo "🔒 Injecting token into New Node ($NEW_IP)..."
                ssh $NEW_USER@$NEW_IP "sudo mkdir -p /var/lib/rancher/k3s/ && echo '$TOKEN' | sudo tee /var/lib/rancher/k3s/cluster-token > /dev/null && sudo chmod 600 /var/lib/rancher/k3s/cluster-token"

                echo "✅ Success! Token safely injected into $NEW_IP."
                echo "🚀 You can now deploy agent.nix to this server."
            '')

            (writeShellScriptBin "open-k3s-monitoring" ''
                set -e

                echo "Extracting Grafana credentials from the cluster..."
                PASSWORD=$(kubectl get secret kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d)

                echo "----------------------------------------"
                echo "🔑 Username: admin"
                echo "🔑 Password: $PASSWORD"
                echo "----------------------------------------"
                echo "🌍 Open your browser to: http://localhost:3000"
                echo "🛑 Press Ctrl+C in this terminal to close the secure tunnel."
                echo "----------------------------------------"
                
                # Start the port forward (this will block the terminal until you press Ctrl+C)
                kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
            '')
        ];
    };
}