{ self, inputs, ... }: {
  flake.homeModules.development = { pkgs, config, lib, ... }:
  let
    dotnet-sdk = pkgs.dotnet-sdk_9;
    rust = inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system}.stable.withComponents [
      "cargo" "clippy" "rust-src" "rustc" "rustfmt" "rust-analyzer"
    ];
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
      rust

      # Dev Tools
      devenv
      obsidian
      blender
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
      CARGO_HOME = "${config.home.homeDirectory}/.cargo";
      RUST_SRC_PATH = "${rust}/lib/rustlib/src/rust/library";

      # Java
      JAVA_HOME = "${pkgs.jdk25}/lib/openjdk";
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
        pkgs.libXxf86vm pkgs.libXtst pkgs.libglvnd pkgs.gtk3              
        pkgs.glib pkgs.cairo pkgs.pango pkgs.atk pkgs.gdk-pixbuf
      ];
    };

    # JDK Source Linking
    home.file.".jdks/nixos-jdk25".source = "${pkgs.jdk25}/lib/openjdk";
  };
}
