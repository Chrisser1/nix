{ ... }: {
  flake.homeModules.jetbrains = { pkgs, ... }: {
    home.packages = with pkgs.jetbrains; [
      # datagrip
      idea
      # goland
    ];
  };
}
