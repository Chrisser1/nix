---
name: rebuild
description: Run the correct NixOS or Home Manager rebuild command for a given target host or context
disable-model-invocation: true
---

Determine the right rebuild command based on $ARGUMENTS (or ask if ambiguous), then run it.

## Available commands

| Alias | What it does |
|-------|-------------|
| `rebuild` | `nh os switch ~/nixos -- --impure` — local NixOS switch (laptop or pc) |
| `update` | `nh os switch ~/nixos --update -- --impure` — update flake inputs first, then switch |
| `rebuild-oracle` | `nixos-rebuild switch --flake ~/nixos#oracle --target-host oracle-server --build-host oracle-server --impure` — deploy to cloud server over SSH |
| `hms` | `home-manager switch --flake /home/chris/nixos#$(hostname)` — Home Manager only, no system changes |

## Logic

- If $ARGUMENTS mentions "oracle" or "cloud" or "server": use `rebuild-oracle`
- If $ARGUMENTS mentions "home" or "home-manager" or "hms": use `hms`
- If $ARGUMENTS mentions "update": use `update`
- If no arguments: ask whether to rebuild locally (NixOS), home-manager only, or oracle

## Important notes

- All commands require `--impure` because the config reads `cluster-vars.json` and `secrets.nix` via `builtins.readFile` at eval time
- `nh` (nix-helper) must be installed; it provides the `rebuild` and `update` aliases
- `rebuild-oracle` builds on the remote host itself — requires SSH access to `oracle-server` (Tailscale must be connected)
- If the build fails due to a broken module, offer to run `nix flake check ~/nixos -- --impure` first to identify the issue

Run the command directly in the terminal after confirming with the user which target to rebuild.
