# NixOS Kubernetes (K3s) Infrastructure

This module manages the core Kubernetes infrastructure for our cloud environment. It uses K3s for lightweight container orchestration, Tailscale for a secure private mesh network, and ArgoCD for GitOps deployments.

## 📂 Architecture

* **`cluster-vars.json`**: The central "brain" of the cluster. Holds the Control Plane IPs, Tailscale IPs, and SSH aliases.
* **`client.nix`**: Installs local CLI tools (`kubectl`, `k9s`) and the `fetch-kubeconfig` script. Apply this to your developer machine.
* **`server.nix`**: Configures the Master Node (Control Plane). Binds internal traffic securely to Tailscale.
* **`agent.nix`**: Configures Worker Nodes. Joins existing servers securely via the Tailscale VPN and cluster token.
* **`deployments.nix`**: Bootstraps the core cluster infrastructure (Prometheus, ArgoCD) directly into the Master Node.


## 🛠️ Operating Procedures

### 1. Setting up a new Developer Machine (Client)
1. Add the `kubernetes-client` module to your local NixOS/Home-Manager config.
2. Run `rebuild` (or your equivalent rebuild command).
3. Run the custom command: `fetch-kubeconfig`.
4. Type `k9s` to access the cluster dashboard.

### 2. Setting up a new Server (Control Plane)
1. Add the `kubernetes-server` and `kubernetes-deployments` modules to the target server's Nix config.
2. Ensure the Cloud provider's hardware firewall has ports `80`, `443`, and `6443` open.
3. Deploy the configuration. The server will boot, start K3s on the Tailscale interface, and install ArgoCD.

### 3. Adding a new Worker Node (Agent)
Agents do not run the Kubernetes API; they only run application Pods. We use Tailscale to create a secure Hybrid Cloud so nodes can be anywhere in the world.

**Step A: Connect to Tailscale**
Log the new machine into Tailscale using the same identity (or profile) as the Control Plane:
```bash
sudo tailscale up
```

**Step B: Secure the Cluster Token**
Pull the secret token from the Master Node and save it locally on the new Agent:

```bash
sudo mkdir -p /var/lib/rancher/k3s/
ssh oracle-server "sudo cat /var/lib/rancher/k3s/server/node-token" | sudo tee /var/lib/rancher/k3s/cluster-token > /dev/null
sudo chmod 600 /var/lib/rancher/k3s/cluster-token
```

**Step C: Deploy & Verify**
Add `self.nixosModules.kubernetes-agent` to the new node's Nix configuration and run `rebuild`. Open `k9s` on your client and type `:nodes` to confirm the new machine has joined.

---

### 4. Moving the Main Server (Stateful Migration)

If you are upgrading to a new server or moving away from Oracle, follow this to preserve your data and GitOps state.

**Step A: Extract the Database (Backup)**
Run this from your laptop to pull the data from the live pod:

```bash
kubectl exec -it -n gymbros deployment/gymbros-db -- pg_dump -U admin -d gymbros -F c > gymbros_migration_backup.dump
```

**Step B: The Brain Transplant**
Update `cluster-vars.json` with the new server's Public IP, Tailscale IP, and SSH alias. Deploy `server.nix` and `deployments.nix` to the new machine.

**Step C: Restore GitOps**
Log into the new ArgoCD UI and re-apply your infrastructure repository bridge file. ArgoCD will instantly rebuild all your application pods (Database, Backend, Frontend).

**Step D: Inject the Data (Restore)**
Push the saved database backup into the new, empty database pod:

```bash
kubectl exec -i -n gymbros deployment/gymbros-db -- pg_restore -U admin -d gymbros -1 < gymbros_migration_backup.dump
kubectl rollout restart deployment gymbros-backend -n gymbros
```