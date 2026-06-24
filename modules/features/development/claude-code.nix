{ self, inputs, ... }: { 
    flake.homeModules.claude-code = { pkgs, ... }: {
        home.packages = [
            inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
        ];
    };
}