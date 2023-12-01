{
  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      devShells.x86_64-linux.default = with pkgs; mkShell {
        packages = [ elixir elixir_ls ];
      };
    };
}
