{ mkDerivation, aeson, base, containers, data-default, fetchgit
, stdenv, time
}:
mkDerivation {
  pname = "scylla";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/ci-realm/data-scylla.git";
    sha256 = "0lc6j03sy88d9kpqn0nmwpq4pwl38iiw93acraijgaifc0x56r4r";
    rev = "84adbbbd2ef89bfe380b3fb4caf8b1e6205ebc4d";
    fetchSubmodules = true;
  };
  libraryHaskellDepends = [
    aeson base containers data-default time
  ];
  homepage = "https://github.com/ci-realm/data-scylla";
  description = "Scylla CI data types";
  license = stdenv.lib.licenses.bsd3;
}
