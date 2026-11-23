{
  description = "Pure Nix OCaml project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ocamlPackages = pkgs.ocamlPackages;
      in
      {
        packages.default = ocamlPackages.buildDunePackage {
          pname = "nix-rwocml-examples";
          version = "0.1.0";
          src = ./.;

          # Add your OCaml library dependencies here
          propagatedBuildInputs = with ocamlPackages; [
            cmdliner
            lwt
          ];

          # Add test dependencies here
          checkInputs = with ocamlPackages; [
            alcotest
          ];
          doCheck = true;
        };

        devShells.default = pkgs.mkShell {
          # Automatically inherits build inputs from packages.default
          inputsFrom = [ self.packages.${system}.default ];

          # Dev-only tools (LSP, formatter, REPL)
          buildInputs = with ocamlPackages; [
            ocaml-lsp
            ocamlformat
            utop
          ];
        };
      });
}

