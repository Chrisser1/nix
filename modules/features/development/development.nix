{ self, ... }: {
  flake.homeModules.development = { pkgs, config, lib, ... }: 
  let
    dotnet-sdk = pkgs.dotnet-sdk_9;
  in {
    home.packages = with pkgs; [
      # Databases
      dbeaver-bin

      # Go
      go
      gcc
      gopls
      delve

      # Java
      jdk25

      # Node & Python
      nodejs_24
      pnpm
      micromamba

      # Latex
      texliveFull
      graphviz
      inkscape

      # Rust
      rustup

      # Dev Tools
      devenv
      obsidian
    ];

    # --- Session Paths ---
    home.sessionPath = [
      "${config.home.homeDirectory}/go/bin"
      "${config.home.homeDirectory}/.cargo/bin"
    ];

    # --- Session Variables ---
    home.sessionVariables = {
      # Go
      GOPATH = "${config.home.homeDirectory}/go";

      # Rust
      RUSTUP_HOME = "${config.home.homeDirectory}/.rustup";
      CARGO_HOME = "${config.home.homeDirectory}/.cargo";

      # Java
      JAVA_HOME = "${pkgs.jdk25}/lib/openjdk";
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
        pkgs.libXxf86vm pkgs.libXtst pkgs.libglvnd pkgs.gtk3              
        pkgs.glib pkgs.cairo pkgs.pango pkgs.atk pkgs.gdk-pixbuf
      ];
    };

    # JDK Source Linking
    home.file.".jdks/nixos-jdk25".source = "${pkgs.jdk25}/lib/openjdk";

    # --- Rust Toolchain Bootstrap ---
    # Installs a default toolchain on first switch only; never fails activation
    # (e.g. when offline), just warns.
    home.activation.rustupDefault = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export RUSTUP_HOME="${config.home.homeDirectory}/.rustup"
      export CARGO_HOME="${config.home.homeDirectory}/.cargo"

      if ! grep -qs '^default_toolchain' "$RUSTUP_HOME/settings.toml"; then
        run ${pkgs.rustup}/bin/rustup default stable \
          && run ${pkgs.rustup}/bin/rustup component add rust-analyzer rust-src \
          || echo "rustup: bootstrap failed (offline?) — run 'rustup default stable' manually"
      fi
    '';
  };
}
