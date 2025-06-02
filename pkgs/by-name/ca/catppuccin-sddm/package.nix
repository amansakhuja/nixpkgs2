{
  lib,
  buildSddmThemePackage,
  stdenvNoCC,
  fetchFromGitHub,
  just,
  flavor ? "mocha",
  themeConfig ? { },
}:
buildSddmThemePackage rec {
  pname = "catppuccin-sddm";
  version = "1.0.0";

  src = stdenvNoCC.mkDerivation {
    pname = "${pname}-src";
    inherit version;

    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "sddm";
      rev = "v${version}";
      hash = "sha256-SdpkuonPLgCgajW99AzJaR8uvdCPi4MdIxS5eB+Q9WQ=";
    };

    nativeBuildInputs = [
      just
    ];

    buildPhase = ''
      runHook preBuild
      just build
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -r dist/ "$out"

      runHook postInstall
    '';
  };

  themeName = "Catppuccin ${flavor}";
  srcThemeDir = "dist/catppuccin-${flavor}";

  configPath = "theme.conf";
  configOverrides = themeConfig;

  meta = {
    description = "Soothing pastel theme for SDDM";
    homepage = "https://github.com/catppuccin/sddm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ elysasrc ];
    platforms = lib.platforms.linux;
  };
}
