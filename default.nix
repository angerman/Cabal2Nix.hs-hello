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

  inherit ((import <haskell>).compat) driver host-map;

  hs-hello = import ./hs-hello.nix;

  # This is a tiny bit better than doJailbreak.
  #
  # We essentially *know* the dependencies, and with the
  # full cabal file representation, we also know all the
  # flags.  As such we can sidestep the solver.
  #
  # Pros:
  #  - no need for doJailbreak
  #    - no need for jailbreak-cabal to be built with
  #      Cabal2 if the cabal file requires it.
  #  - no reliance on --allow-newer, which only made
  #    a very short lived appearance in Cabal.
  #    (Cabal-2.0.0.2 -- Cabal-2.2.0.0)
  #
  # Cons:
  #  - automatic flag resolution won't happen and will
  #    have to be hard coded.
  #
  # Ideally we'd just inspect the haskell*Depends fields
  # we feed the builder. However because we null out the
  # lirbaries ghc ships (e.g. base, ghc, ...) this would
  # result in an incomplete --dependency=<name>=<name>-<version>
  # set and not lead to the desired outcome.
  #
  # If we could still have base, etc. not nulled, but
  # produce some virtual derivation, that might allow us
  # to just use the haskell*Depends fields to extract the
  # name and version for each dependency.
  #
  # Ref: https://github.com/haskell/cabal/issues/3163#issuecomment-185833150
  # ---
  # ghc-pkg should be ${ghcCommand}-pkg; and --package-db
  # should better be --${packageDbFlag}; but we don't have
  # those variables in scope.
  doExactConfig = pkg: pkgs.lib.overrideDerivation pkg (drv: {
    preConfigure = (drv.preConfigure or "") + ''
    configureFlags+=" --exact-configuration"
    globalPackages=$(ghc-pkg list --global --simple-output)
    localPackages=$(ghc-pkg --package-db="$packageConfDir" list --simple-output)
    for pkg in $globalPackages; do
      if [ "''${pkg%-*}" != "rts" ]; then
        configureFlags+=" --dependency="''${pkg%-*}=$pkg
      fi
    done
    for pkg in $localPackages; do
      configureFlags+=" --dependency="''${pkg%-*}=$pkg
    done
'';
  });
  # Create the hello derivation.
  hello = driver { cabalexpr = hs-hello; pkgs = pkgs;
                   inherit (host-map pkgs.stdenv) os arch;
                   version = pkgs.haskellPackages.compiler.ghc.version; };
in
  # build the packge.  NOTE: with cabal2nix we could
  # provide additional package modifications in the
  # additional arguments to `callPackage`, with
  # Cabal2Nix we can not use this mechanism, as it
  # picks the haskell packages from pkgs.haskellPackages.
  let myPkgs = rec { hello0 = hello;
        hello1 = pkgs.haskellPackages.callPackage hello0;
        hello2 = hello1 {};
      };
  in doExactConfig myPkgs.hello2
#  pkgs.haskellPackages.callPackage hello {}
