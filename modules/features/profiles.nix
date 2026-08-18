{ self, inputs, ... }: {
  flake.homeModules.profile-chris = {...}: {
    imports = [
      # For easy connection to servers
      inputs.k3s-cluster.homeModules.ssh

      # Window manager and related packages
      self.homeModules.hyprland
      self.homeModules.noctalia

      # Terminal
      self.homeModules.cli
      self.homeModules.gui-terminal
      self.homeModules.shell-aliases
      self.homeModules.tmux

      # Kubernetes client connection to server
      inputs.k3s-cluster.homeModules.kubernetes-client

      # Everyday use
      self.homeModules.starship
      self.homeModules.git
      self.homeModules.nautilus
      self.homeModules.clipboard
      self.homeModules.appearance
      self.homeModules.development
      # self.homeModules.jetbrains
      self.homeModules.search
      self.homeModules.vscode
      self.homeModules.wdisplays
      self.homeModules.gromit-mpx
      self.homeModules.bitwarden
      self.homeModules.hypr-screen-mirror
      self.homeModules.nix-monitor

      # AI tools
      self.homeModules.claude-code
    ];
  };

  flake.homeModules.profile-work = {...}: {
    imports = [
      # Window manager and related packages
      self.homeModules.hyprland
      self.homeModules.noctalia

      # Terminal
      self.homeModules.cli
      self.homeModules.gui-terminal
      self.homeModules.shell-aliases
      self.homeModules.tmux

      # Everyday use
      self.homeModules.starship
      self.homeModules.git
      self.homeModules.nautilus
      self.homeModules.clipboard
      self.homeModules.appearance
      self.homeModules.development
      # self.homeModules.jetbrains
      self.homeModules.search
      self.homeModules.vscode
      self.homeModules.wdisplays
      self.homeModules.gromit-mpx
      self.homeModules.bitwarden
      self.homeModules.hypr-screen-mirror
      self.homeModules.nix-monitor

      self.homeModules.work-mounts

      # AI tools
      self.homeModules.claude-code
    ];
  };
}
