{
  lib,
  stdenv,
  fetchFromGitHub,
  wrapGAppsHook4,
  nix-update-script,

  appstream,
  bubblewrap,
  flatpak,
  glycin-loaders,
  gtk4,
  json-glib,
  libadwaita,
  libdex,
  libglycin,
  libsoup_3,
  libxmlb,
  libyaml,

  desktop-file-utils,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bazaar";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "kolunmi";
    repo = "bazaar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QzzWj6KjyKNMBHQ/RqvUSL6QeokgvK2Fc+23kkt3SMM=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    appstream
    flatpak
    gtk4
    json-glib
    libadwaita
    libdex
    (libglycin.overrideAttrs (
      _final: prev: {
        patches = (if prev ? patches then prev.patches else [ ]) ++ [
          # Otherwise the PATH will be cleared and bwrap could not be found
          ./libglycin-no-clearenv.patch
        ];
      }
    ))
    libsoup_3
    libxmlb
    libyaml
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ bubblewrap ]}"
      --prefix XDG_DATA_DIRS : "${glycin-loaders}/share"
    )
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "New FlatHub-first app store for GNOME";
    homepage = "https://github.com/kolunmi/bazaar";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "bazaar";
    platforms = lib.platforms.linux;
  };
})
