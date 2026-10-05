{
  description = "My system configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Core framework
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gslapper = {
      url = "github:Nomadcxx/gSlapper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    split-monitor-workspaces = {
      url = "github:zjeffer/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
    claude-code.url = "github:sadjow/claude-code-nix";
    qylock.url = "github:Darkkal44/qylock";
    
    nyx = {
      url = "git+file:///home/chris/repos/nyx";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.gslapper.follows = "gslapper";
      inputs.flake-parts.follows = "flake-parts";
      inputs.import-tree.follows = "import-tree";
    };

    sigil-sddm = {
      url = "github:Clusterforgers/sigil-sddm-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grubermeister.url = "github:N1njaflam1ng0/grubermeister";

    k3s-cluster.url = "github:Clusterforgers/k3s-cluster";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
    {inherit inputs;}
    (inputs.import-tree ./modules);
}
