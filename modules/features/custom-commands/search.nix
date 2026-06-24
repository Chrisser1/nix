{ self, ... }: {
  flake.homeModules.search = { pkgs, lib, ... }: 
  let
    my-dependencies = with pkgs; [
      ripgrep-all fzf bat ffmpeg kdePackages.okular
    ];

    universal-search = pkgs.writeShellScriptBin "search" ''
      #!/usr/bin/env bash
      export PATH="${lib.makeBinPath my-dependencies}:$PATH"

      if ! command -v rga &> /dev/null; then
          echo "Error: ripgrep-all (rga) is not installed."
          exit 1
      fi

      RG_PREFIX="rga --files-with-matches --ignore-case"

      output=$(
        FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
        fzf --sort \
            --disabled \
            --print-query \
            --query "$1" \
            --bind "change:reload:$RG_PREFIX {q}" \
            --layout=reverse \
            --preview='rga --ignore-case --pretty --context 5 {q} {}' \
            --preview-window="up,70%:wrap" \
            --header="ENTER to open in Okular | Type to search | ESC to exit"
      )

      if [[ -z "$output" ]]; then exit 0; fi

      query=$(echo "$output" | head -n 1)
      file=$(echo "$output" | tail -n 1)

      if [[ -n "$file" ]]; then
          if [[ "$file" == *.pdf ]]; then
              echo "Opening $file matching '$query' in Okular..."
              nohup okular --find "$query" "$file" >/dev/null 2>&1 &
          else
              xdg-open "$file"
          fi
      fi
    '';
  in {
    home.packages = my-dependencies ++ [ universal-search ];
  };
}