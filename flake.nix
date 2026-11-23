# nix-hermetic-ocaml
{
  description = "nix-hermetic-ocaml";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = { self, nixpkgs }: 
    let
      aarch64-darwin = import nixpkgs { system = "aarch64-darwin"; };
      aarch64-linux = import nixpkgs { system = "aarch64-linux"; };
      x86_64-linux = import nixpkgs { system = "x86_64-linux"; };

      default = { pkgs }: pkgs.stdenv.mkDerivation {
        name = "nix-hermetic-ocaml";
        src = ./.;
        buildInputs = [ pkgs.ocaml ];
        
        buildPhase = ''
        '';

        installPhase = ''
          mkdir -p $out/bin
          echo "#!/bin/sh" > $out/bin/nix-hermetic-ocaml
          echo "${pkgs.ocaml}/bin/ocaml" >> $out/bin/nix-hermetic-ocaml
          chmod +x $out/bin/nix-hermetic-ocaml
        '';
      };
    in {
      packages.aarch64-darwin.default = default { pkgs = aarch64-darwin; };
      packages.aarch64-linux.default = default { pkgs = aarch64-linux; };
      packages.x86_64-linux.default = default { pkgs = x86_64-linux; };
    };
}

