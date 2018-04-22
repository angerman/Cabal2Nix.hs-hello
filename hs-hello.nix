{ compiler, flags ? {}, hsPkgs, pkgconfPkgs, pkgs, system }:
let
    _flags = {} // flags;
    in {
      flags = _flags;
      package = {
        specVersion = "1.10";
        identifier = {
          name = "hs-hello";
          version = "0.1.0.0";
        };
        license = "BSD-3-Clause";
        copyright = "";
        maintainer = "moritz.angermann@gmail.com";
        author = "Moritz Angermann";
        homepage = "";
        url = "";
        synopsis = "";
        description = "";
        buildType = "Simple";
      };
      components = {
        exes = {
          hs-hello = {
            depends  = [ hsPkgs.base ];
          };
        };
      };
    } // { src = ./.; }
