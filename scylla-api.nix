{ mkDerivation, aeson, ansi-wl-pprint, base, binary, bytestring
, containers, data-default, mtl, network, scylla, split, stdenv
, stm, text, time, websockets, wuss
}:
mkDerivation {
  pname = "scylla-api";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson ansi-wl-pprint base binary bytestring containers data-default
    mtl network scylla split stm text time websockets wuss
  ];
  executableHaskellDepends = [
    aeson base bytestring containers data-default mtl scylla stm text
  ];
  homepage = "https://github.com/ci-realm/scylla-api";
  description = "API for Scylla CI";
  license = stdenv.lib.licenses.bsd3;
}
