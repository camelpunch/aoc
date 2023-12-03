{
  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      common = {
        lines = input: (builtins.filter (line: line != "") (pkgs.lib.strings.splitString "\n" input));
      };
      callPackage = pkgs.lib.callPackageWith (pkgs // common);
    in
    {
      devShells.x86_64-linux.default = with pkgs; mkShell {
        packages = [ elixir elixir_ls ];
      };
      day01 = callPackage ./day01.nix { };
      day02 = callPackage ./day02.nix { };
    };
}
