{ self, ... }: {
  flake.homeModules.development = { pkgs, config, lib, ... }: 
  let
    dotnet-sdk = pkgs.dotnet-sdk_9;
  in {
    home.packages = with pkgs; [
      # Databases
      dbeaver-bin
      jetbrains.datagrip
      
      # .NET
      dotnet-sdk
      nuget
      jetbrains.rider
      
      # Go
      go
      gcc
      gopls   
      delve   
      jetbrains.goland
      
      # Java
      jdk25
      jetbrains.idea
      
      # Node & Python
      nodejs_24
      pnpm
      micromamba

      # Latex
      texliveFull
      graphviz
      inkscape

      # Dev Tools
      devenv
      obsidian
    ];

    # --- Session Paths ---
    home.sessionPath = [
      "${config.home.homeDirectory}/.dotnet/tools"
      "${config.home.homeDirectory}/go/bin"
    ];

    # --- Session Variables ---
    home.sessionVariables = {
      # .NET
      DOTNET_CLI_TELEMETRY_OPTOUT = "1";   
      DOTNET_NOLOGO = "1";                 
      DOTNET_ROOT = "${dotnet-sdk}";       
      
      # Go
      GOPATH = "${config.home.homeDirectory}/go";
      
      # Java
      JAVA_HOME = "${pkgs.jdk25}/lib/openjdk";
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
        pkgs.libXxf86vm pkgs.libXtst pkgs.libglvnd pkgs.gtk3              
        pkgs.glib pkgs.cairo pkgs.pango pkgs.atk pkgs.gdk-pixbuf
      ];
    };

    # --- JDK Source Linking ---
    home.file.".jdks/nixos-jdk25".source = "${pkgs.jdk25}/lib/openjdk";
  };
}