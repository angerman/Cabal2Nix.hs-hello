# This is an example file highlighting the use of
# the `Cabal2Nix` tool.  The `Cabal2Nix` tool converts
# a `.cabal` file into a nix-expression retaining the
# os/arch/flag branches.
#
# To turn the generated nix-expression into one that is
# compatible with the generic haskell builder, and to
# obtain a mostly `cabal2nix` compatible derivation, a
# `nix/driver.nix` expression is provided.
#
# This expression show the usage of such an expression
# within nix.
#
# After obtaining `Cabal2Nix`[1], run
#
# $ Cabal2Nix hs-hello.cabal > hs-hello.nix
#
# This `default.nix` then turns the `hs-hello.nix` expression
# into a derivation that can be fed into `callPackage`.
#
let
  overlay = self: super: {
    haskellPackages = (import <stackage>).lts-9_1
      { extraDeps = hsPkgs: { hs-hello = ./hs-hello.nix; };
      };
  };

  pkgs = import <nixpkgs> { overlays = [ overlay ]; };

in
  pkgs.haskellPackages
