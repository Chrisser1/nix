{ ... }: {
  flake.homeModules.tmux = { pkgs, lib, ... }: {
    programs.tmux = {
      enable = true;
      shortcut = "b";
      keyMode = "vi";
      mouse = true;

      extraConfig = ''
        bind -n M-Left previous-window
        bind -n M-Right next-window

        # Create a new window (Workspace) with Super + Up
        bind -n M-Up new-window

        # Close a window (Workspace) with Super + Down
        bind -n M-Down confirm-before -p "Kill window? (y/n)" kill-window
        set -g status-left "#{?client_prefix,#[fg=black]#[bg=yellow]#[bold] PREFIX }"

        set -g allow-passthrough on
        set -s extended-keys on
        set -as terminal-features 'xterm*:extkeys'

        # Split panes in the current path
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        # Navigate panes with Alt + hjkl
        bind -n M-h select-pane -L
        bind -n M-j select-pane -D
        bind -n M-k select-pane -U
        bind -n M-l select-pane -R
      '';
    };
  };
}
