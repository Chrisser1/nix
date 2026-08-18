{ ... }: {
  flake.nixosModules.package-overrides = { ... }: {
    nixpkgs.overlays = [
      # libmamba 2.6.2 fails to build against fmt 12: it calls fmt::format while only
      # pulling in fmt/base.h (fmt 12 no longer declares format there). Build the mamba
      # stack against fmt 11 instead, spdlog included so both link the same fmt.
      #
      # To check whether nixpkgs has fixed this and the override can be dropped, build
      # micromamba straight from the pinned input, bypassing this overlay:
      #
      #   nix build --impure --no-link --expr \
      #     '(builtins.getFlake "/home/chris/nixos").inputs.nixpkgs.legacyPackages.x86_64-linux.micromamba'
      #
      # The warning below fires on eval once nixpkgs moves off 2.6.2, as a reminder to try.
      (final: prev: let
        inherit (prev) lib;

        # The libmamba version this workaround was written against.
        patchedVersion = "2.6.2";

        spdlog-fmt11 = prev.spdlog.override { fmt = prev.fmt_11; };

        stillNeeded = lib.warnIf (prev.libmamba.version != patchedVersion) ''
          package-overrides: libmamba is now ${prev.libmamba.version}, but the fmt 12 workaround
          was written for ${patchedVersion}. Check whether it is still needed and drop it if not —
          see modules/features/system/package-overrides.nix.
        '';
      in {
        libmamba = stillNeeded (prev.libmamba.override {
          fmt = prev.fmt_11;
          spdlog = spdlog-fmt11;
        });

        mamba-cpp = prev.mamba-cpp.override {
          libmamba = final.libmamba;
          spdlog = spdlog-fmt11;
        };
      })
    ];
  };
}
