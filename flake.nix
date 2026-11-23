# nix-hermetic-ocaml
{
  description = "nix-hermetic-ocaml";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = { self, nixpkgs }: 
    let
      # Define systems
      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ];

      # Helper to get pkgs for a specific system
      getPkgs = system: import nixpkgs { system = system; };

      # Helper to build the shell for a specific system
      mkHermeticShell = system: 
        let
          pkgs = getPkgs system;
        in
          pkgs.mkShell {
            buildInputs = [ pkgs.ocaml pkgs.coreutils ];
            
            # The shellHook runs when you enter 'nix develop'
            shellHook = ''
              # Overwrite PATH completely. 
              # We include coreutils so basic commands (ls, cd) work.
              export PATH="${pkgs.lib.makeBinPath [ pkgs.ocaml pkgs.coreutils ]}"
              
              # Redirecting all status messages to stderr using >&2
              echo "-------------------------------------------------------" >&2
              echo "HERMETIC ENVIRONMENT ACTIVE" >&2
              echo "PATH is restricted to OCaml and Coreutils." >&2
              echo "PATH: $PATH" >&2
              echo "-------------------------------------------------------" >&2
            '';
          };

      # Define the derivation
      default = { pkgs }: pkgs.stdenv.mkDerivation {
        name = "nix-hermetic-ocaml";
        src = ./.;
        buildInputs = [ pkgs.ocaml ];
        buildPhase = "";
        installPhase = ''
          mkdir -p $out/bin
          echo "#!/bin/sh" > $out/bin/nix-hermetic-ocaml
          echo "${pkgs.ocaml}/bin/ocaml" >> $out/bin/nix-hermetic-ocaml
          chmod +x $out/bin/nix-hermetic-ocaml
        '';
      };
    in {
      # Packages
      packages.aarch64-darwin.default = default { pkgs = getPkgs "aarch64-darwin"; };
      packages.aarch64-linux.default = default { pkgs = getPkgs "aarch64-linux"; };
      packages.x86_64-linux.default = default { pkgs = getPkgs "x86_64-linux"; };

      # Dev Shells (Now correctly defined as a Set)
      devShells = {
        aarch64-darwin.default = mkHermeticShell "aarch64-darwin";
        aarch64-linux.default = mkHermeticShell "aarch64-linux";
        x86_64-linux.default = mkHermeticShell "x86_64-linux";
      };
    };
}
