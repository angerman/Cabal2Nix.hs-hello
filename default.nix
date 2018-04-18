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
  pkgs = import <nixpkgs> { };
  driver = import ./nix/driver.nix;
  host-map = import ./nix/host-map.nix;
  hs-hello = import ./hs-hello.nix;

  # mkLocal will inject `src = ./.` into the derivation, making the
  # generic builder build the package in the current directory instead
  # of trying to download it from hackage.
  mkLocal = drv: pkgs.haskell.lib.overrideCabal drv (drv: { src = ./.; });
  # Create the hello derivation.
  hello = driver { cabalexpr = hs-hello; pkgs = pkgs;
                   inherit (host-map pkgs.stdenv) os arch; };
in
  # build the packge.  NOTE: with cabal2nix we could
  # provide additional package modifications in the
  # additional arguments to `callPackage`, with
  # Cabal2Nix we can not use this mechanism, as it
  # picks the haskell packages from pkgs.haskellPackages.
  mkLocal (pkgs.haskellPackages.callPackage hello {})
