{ mkDerivation, aeson, base, containers, data-default, fetchgit
, stdenv, time
}:
mkDerivation {
  pname = "scylla";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/ci-realm/data-scylla.git";
    sha256 = "1w1xxzvrx2cjnz300d48qsarag552pq84r2mbm00k17y27km9ncd";
    rev = "7db0ad3222a422c5490934235a4572ea26e46c2f";
    fetchSubmodules = true;
  };
  libraryHaskellDepends = [
    aeson base containers data-default time
  ];
  homepage = "https://github.com/ci-realm/data-scylla";
  description = "Scylla CI data types";
  license = stdenv.lib.licenses.bsd3;
}
