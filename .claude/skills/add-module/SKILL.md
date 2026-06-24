---
name: add-module
description: Scaffold a new feature module in this NixOS config following the flake-parts + import-tree pattern
---

Help the user add a new feature module to `modules/features/`. The module will be auto-discovered by `import-tree` — no manual registration needed.

## Step 1: Clarify scope

Ask (or infer from $ARGUMENTS):
1. **Module name** — what to call it (e.g., `neovim`, `docker`, `vpn`)
2. **Scope** — NixOS system module, Home Manager module, or both?
3. **Purpose** — brief description of what it configures

## Step 2: Propose the file path and structure

- Target file: `modules/features/<name>.nix`
- If it needs a subdirectory (multiple related files): `modules/features/<name>/default.nix` plus siblings

Show the user the skeleton before writing it.

## Step 3: Write the module

**Home Manager module only:**
```nix
{ self, inputs, ... }: {
  flake.homeModules.<name> = { pkgs, lib, config, ... }: {
    # home-manager options here
  };
}
```

**NixOS system module only:**
```nix
{ self, inputs, ... }: {
  flake.nixosModules.<name> = { pkgs, lib, config, ... }: {
    # nixos options here
  };
}
```

**Both (system + home):**
```nix
{ self, inputs, ... }: {
  flake.nixosModules.<name> = { pkgs, lib, config, ... }: {
    # system-level config (services, security, networking, etc.)
  };

  flake.homeModules.<name> = { pkgs, lib, config, ... }: {
    # per-user config (dotfiles, programs, env vars, etc.)
  };
}
```

## Step 4: Wire it into a host

After writing the module, show the user how to enable it in a host's `default.nix`. Look at an existing host (e.g., `modules/hosts/laptop/default.nix`) for the pattern — modules are listed in the `modules` array of `nixosConfigurations` or `homeModules` of the home-manager config.

## Step 5: Verify

Remind the user to run `rebuild` (or `nix flake check ~/nixos -- --impure`) to catch eval errors before committing.

## Notes

- `import-tree` picks up any `.nix` file under `modules/` automatically — no need to add imports manually
- Use `inputs.<flake-name>.packages.${pkgs.system}.<pkg>` to reference packages from flake inputs (e.g., Hyprland, NVF)
- Access secrets via `import "/home/chris/nixos/secrets.nix"` (hardcoded path — same as other modules)
- The `{ self, inputs, ... }:` top-level args are flake-parts module args, not NixOS module args
