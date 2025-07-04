{
  lib,
  alsa-lib,
  cmake,
  fetchFromGitHub,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libremidi";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "jcelerier";
    repo = "libremidi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FyrbqE2EyxAxxLbmY86tmAYLa39ntwy9DGtMLxGvxbs=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
  ];

  # Bug: set this as true breaks obs-studio-plugins.advanced-scene-switcher
  strictDeps = false;

  # PipeWire support currently disabled. Enabling it requires packaging:
  # https://github.com/cameron314/readerwriterqueue
  cmakeFlags = [ "-DLIBREMIDI_NO_PIPEWIRE=ON" ];

  postInstall = ''
    cp -r $src/include $out
  '';

  meta = {
    homepage = "https://github.com/jcelerier/libremidi";
    description = "Modern C++ MIDI real-time & file I/O library";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
