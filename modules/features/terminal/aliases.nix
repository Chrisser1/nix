{ self, ... }: {
  flake.homeModules.shell-aliases = { pkgs, ... }: {
    programs.fish.shellAliases = let
      flakePath = "$HOME/nixos";
    in {
      vim = "nvim";
      rebuild = "nh os switch ~/nixos -- --impure";
      update = "nh os switch ~/nixos --update -- --impure";
      clean = "nh clean all --keep 3 && rm -rf ~/.local/share/Trash/*";
      usage = "gdu /";
      store-map = "nix-tree -- /run/current-system";
      roots = "nix-store --gc --print-roots | grep -v '/proc/'";
      hms = "home-manager switch --flake ${flakePath}#$(hostname)";
      dn = "dotnet";
      db = "dotnet build";
      dr = "dotnet run";
      dt = "dotnet test";
      ssh = "kitten ssh";
      
      rebuild-oracle = "nixos-rebuild switch --flake ~/nixos#oracle --target-host oracle-server --build-host oracle-server --impure";
    };
  };
}