{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc843" }:
let
  scylla = nixpkgs.haskell.packages.${compiler}.callPackage ./data-scylla.nix {};
  pretty-relative-time = nixpkgs.haskell.packages.${compiler}.callPackage ./pretty-relative-time.nix {};
in
nixpkgs.haskell.packages.${compiler}.callPackage ./scylla-api.nix { inherit scylla pretty-relative-time; }
