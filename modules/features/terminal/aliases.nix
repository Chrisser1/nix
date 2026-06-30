{ self, ... }: {
  flake.homeModules.shell-aliases = { config, pkgs, ... }: {
    home.sessionVariables.NH_FLAKE = "${config.home.homeDirectory}/nixos";

    programs.fish.shellAliases = {
      vim = "nvim";
      rebuild = "nh os switch -- --impure";
      update = "nh os switch --update -- --impure";
      clean = "nh clean all --keep 3 && rm -rf ~/.local/share/Trash/*";
      usage = "gdu /";
      store-map = "nix-tree -- /run/current-system";
      roots = "nix-store --gc --print-roots | grep -v '/proc/'";
      hms = "home-manager switch --flake $FLAKE#$(hostname)";
      dn = "dotnet";
      db = "dotnet build";
      dr = "dotnet run";
      dt = "dotnet test";
      ssh = "kitten ssh";
    };
  };
}
