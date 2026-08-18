{ ... }: {
  flake.nixosModules.package-overrides = { ... }: {
    nixpkgs.overlays = [
      # libmamba 2.6.2 fails to build against fmt 12: it calls fmt::format while only
      # pulling in fmt/base.h (fmt 12 no longer declares format there). Build the mamba
      # stack against fmt 11 instead, spdlog included so both link the same fmt.
      (final: prev: let
        spdlog-fmt11 = prev.spdlog.override { fmt = prev.fmt_11; };
      in {
        libmamba = prev.libmamba.override {
          fmt = prev.fmt_11;
          spdlog = spdlog-fmt11;
        };

        mamba-cpp = prev.mamba-cpp.override {
          libmamba = final.libmamba;
          spdlog = spdlog-fmt11;
        };
      })
    ];
  };
}
