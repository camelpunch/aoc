{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    idris2Pkgs.url = "github:idris-lang/Idris2";
  };

  outputs = { self, nixpkgs, idris2Pkgs }:
    let
      idris2 = idris2Pkgs.packages.x86_64-linux.idris2;
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      common = {
        lines = input: (builtins.filter (line: line != "") (pkgs.lib.strings.splitString "\n" input));
      };
      callPackage = pkgs.lib.callPackageWith (pkgs // common);

      day03 = pkgs.stdenv.mkDerivation {
        name = "day03";
        src = ./.;
        allowSubstitutes = false;
        nativeBuildInputs = [ idris2 ];
        buildPhase = ''
          build_dir="$(pwd)"
          (
          cd $src
          idris2 \
            --output day03 \
            --build-dir "$build_dir" \
            day03.idr
          )
          mkdir -p $out/bin
          cp -a "$build_dir/exec/." $out/bin/
        '';
      };
    in
    {
      devShells.x86_64-linux.default = with pkgs; mkShell {
        packages = [
          day03
          elixir
          elixir_ls
          idris2
          rlwrap
        ];
      };
      day01 = callPackage ./day01.nix { };
      day02 = callPackage ./day02.nix { };
    };
}
