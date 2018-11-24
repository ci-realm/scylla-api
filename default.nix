{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc843" }:
let
  scylla = nixpkgs.haskell.packages.${compiler}.callPackage ./data-scylla.nix {};
in
nixpkgs.haskell.packages.${compiler}.callPackage ./scylla-api.nix { inherit scylla; }
