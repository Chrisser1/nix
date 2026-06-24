# CLAUDE.md

Personal preferences for working with this NixOS config repo.

## My background

Comfortable with Nix/NixOS but still mapping out the structure of this specific flake. Know how modules, overlays, and flake outputs work — just learning where everything lives in this repo. No need to explain basic Nix concepts, but do orient to how this flake's conventions work when relevant (flake-parts + import-tree pattern, how homeModules vs nixosModules are declared, etc.).

## Communication style

- Be terse — skip trailing summaries of what you just did
- Propose a plan (which files you'll touch, what you'll change) before making edits
- When restructuring modules or changing option paths, call out tradeoffs
- Before using any Hyprland config option, tool, or NixOS module option, check the current docs/wiki for the correct up-to-date syntax — APIs change frequently and outdated options cause config errors
