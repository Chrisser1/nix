# NixOS Kubernetes (K3s) Infrastructure

K3s for container orchestration, Tailscale for secure mesh networking, ArgoCD for GitOps deployments. Supports multiple servers defined in a single JSON file.

## Architecture

| File | Purpose |
|------|---------|
| `cluster-vars.json` | Single source of truth for all servers (IPs, SSH aliases, roles) |
| `ssh.nix` | Generates SSH client config entries for every server in the list |
| `client.nix` | CLI tools + scripts for developer machines (`kubectl`, `k9s`, `fetch-kubeconfig`, `bootstrap-node`) |
| `server.nix` | K3s control plane config, apply to the server with `"role": "control-plane"` |
| `agent.nix` | K3s worker node config, joins the control plane via Tailscale |
| `deployments.nix` | Core cluster infrastructure (Prometheus, ArgoCD) bootstrapped onto the control plane |

---

## Adding a New Server

All server configuration lives in `cluster-vars.json`. Append an entry to the `servers` array:

```json
{
  "name": "my-server",
  "nixosAttr": "my-server",
  "sshAlias": "my-server",
  "ip": "1.2.3.4",
  "tailscaleIp": "100.x.x.x",
  "sshUser": "root",
  "sshKey": "~/.ssh/your-key.key",
  "role": "agent"
}
```

| Field | Description |
|-------|-------------|
| `name` | Used as suffix for shell aliases (`rebuild-<name>`, `update-<name>`, `clean-<name>`) |
| `nixosAttr` | The `nixosConfigurations.<attr>` key in the flake |
| `sshAlias` | The SSH `Host` entry written to `~/.ssh/config` |
| `ip` | Public IP, used for TLS SANs and kubeconfig patching |
| `tailscaleIp` | Tailscale IP, K3s binds cluster traffic to this |
| `sshKey` | Path to the private key on your local machine |
| `role` | `"control-plane"` or `"agent"`, scripts use this to find the right server automatically |

After editing, run `rebuild` on your local machine to apply the new SSH config and generate the new aliases.

---

## Bootstrapping a New NixOS Server (First Deploy)

`nixos-rebuild --build-host` requires the server's hostname to match a `nixosConfigurations` entry in the flake. A freshly provisioned server often has a different hostname, so the first deploy must be done manually.

**Step 1 — Add the server to `cluster-vars.json`** and create its `nixosConfigurations` entry in the flake. Add its SSH public key to `secrets.nix`.

**Step 2 — Copy the flake to the server:**
```sh
rsync -avz ~/nixos/ <ssh-alias>:/tmp/nixos/
```

**Step 3 — Copy `secrets.nix`** (referenced by absolute path, not included in the flake source):
```sh
command ssh <ssh-alias> 'mkdir -p /home/chris/nixos'
rsync ~/nixos/secrets.nix <ssh-alias>:/home/chris/nixos/secrets.nix
```

**Step 4 — Fix ownership and rebuild on the server natively:**
```sh
command ssh <ssh-alias> 'chown -R root:root /tmp/nixos && nixos-rebuild switch --flake /tmp/nixos#<nixosAttr> --impure'
```

> Use `command ssh` instead of `ssh` — the `ssh` alias points to `kitten ssh` which requires a TTY and fails for non-interactive commands.

**Step 5 — Fix the running hostname** (NixOS sets `/etc/hostname` but the kernel hostname may not update until reboot on some cloud providers):
```sh
command ssh <ssh-alias> 'hostname <nixosAttr>'
```

**Step 6 — All future deploys work normally:**
```sh
rebuild-<name>    # rebuild with current flake lock
update-<name>    # update flake inputs, then rebuild
clean-<name>     # run nix garbage collection on the server
```

---

## Setting Up a Developer Machine

1. Add `self.homeModules.kubernetes-client` to your home-manager profile.
2. Run `rebuild`.
3. Run `fetch-kubeconfig` to pull the kubeconfig from the control plane.
4. Run `k9s` to connect to the cluster.

`fetch-kubeconfig` defaults to the control plane server. To target a specific server:
```sh
fetch-kubeconfig <ssh-alias>
```

---

## Adding a Worker Node (Agent)

**Step 1 — Add the node to `cluster-vars.json`** with `"role": "agent"`, create its NixOS config importing `self.nixosModules.kubernetes-agent`, and bootstrap it following the steps above.

**Step 2 — Connect to Tailscale:**
```sh
command ssh <ssh-alias> 'tailscale up'
```

**Step 3 — Inject the cluster token from your local machine:**
```sh
bootstrap-node <new-server-ip> <ssh-user>
```

This pulls the token from the control plane and writes it securely to the new node.

**Step 4 — Verify in k9s:**
```sh
k9s
# type :nodes
```

---

## Moving the Control Plane

**Step 1 — Back up the database:**
```sh
kubectl exec -it -n gymbros deployment/gymbros-db -- pg_dump -U admin -d gymbros -F c > gymbros_migration_backup.dump
```

**Step 2 — Update `cluster-vars.json`** with the new server's IPs and SSH alias. Bootstrap the new server, applying `kubernetes-server` and `kubernetes-deployments`.

**Step 3 — Restore GitOps:** Re-sync ArgoCD on the new server. ArgoCD rebuilds all application pods from the Git state.

**Step 4 — Restore the database:**
```sh
kubectl exec -i -n gymbros deployment/gymbros-db -- pg_restore -U admin -d gymbros -1 < gymbros_migration_backup.dump
kubectl rollout restart deployment gymbros-backend -n gymbros
```
