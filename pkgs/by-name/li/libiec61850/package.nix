{
  cmake,
  mbedtls,
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libiec61850";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "mz-automation";
    repo = "libiec61850";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KFUqeDe90wrqMueD8AYgB1scl6OZkKW2z+oV9wREF3k=";
  };

  separateDebugInfo = true;

  cmakeFlags = [
    "-DCONFIG_USE_EXTERNAL_MBEDTLS_DYNLIB=ON"
    "-DCONFIG_EXTERNAL_MBEDTLS_DYNLIB_PATH=${mbedtls}/lib"
    "-DCONFIG_EXTERNAL_MBEDTLS_INCLUDE_PATH=${mbedtls}/include"
  ];

  nativeBuildInputs = [
    cmake
    mbedtls
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Open-source library for the IEC 61850 protocols";
    homepage = "https://libiec61850.com/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      stv0g
      pjungkamp
    ];
    platforms = lib.platforms.unix;
  };
})
