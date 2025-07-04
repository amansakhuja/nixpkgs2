{
  lib,
  stdenv,
  cudatoolkit,
  autoAddDriverRunpath,
  cudaPackages,
  fetchFromGitHub,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mfaktc";
  version = "0.23.4";

  src = fetchFromGitHub {
    owner = "primesearch";
    repo = "mfaktc";
    tag = "${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-BlCAKzRFYPv4SYSBhNd+9yXw1PVNGkbqn2lsNeJ526A=";
  };

  enableParallelBuilding = true;
  nativeBuildInputs = [
    cudatoolkit
    cudaPackages.cuda_cudart
    autoAddDriverRunpath
  ];

  sourceRoot = "${finalAttrs.src.name}/src";

  preBuild = ''
    chmod +w ..
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 ../mfaktc $out/bin

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgramArg = "-h";

  meta = {
    description = "Trial Factoring program using CUDA for GIMPS";
    longDescription = ''
      CUDA Program for trial factoring Mersenne primes. Intented for use with GIMPS through autoprimenet.py.
      Attention: You need to supply your own mfaktc.ini, which needs to be in the running directory.
    '';
    homepage = "https://github.com/primesearch/mfaktc";
    downloadPage = "https://github.com/primesearch/mfaktc/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ dstremur ];
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
})
