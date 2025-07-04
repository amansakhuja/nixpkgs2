{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  nodejs,
  pnpm_9,
  pkg-config,
  libayatana-appindicator,
  glib,
  gtk3,
  webkitgtk_4_1,
  wrapGAppsHook4,
  glib-networking,
  cacert,
  libXtst,
  xdg-utils,
  jq,
  makeWrapper,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bongocat";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "ayangweb";
    repo = "BongoCat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-P+u03ttmIre9kJ8m1DJhDvn3HaD3hibowyPzhqptIu0=";
  };

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-NI0kyXlARPjpSgmlDq8WiSBdd8WAh0c7TiskHQE1VGI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-Kq9A0qB4OLeMHWKqTRO2wlkQQYfpN2dMeUXwghTN7uY=";

  cargoRoot = "./";
  buildAndTestSubdir = "src-tauri";

  tauriBundleType = "deb";

  nativeBuildInputs =
    [
      cargo-tauri.hook
      nodejs
      pnpm_9.configHook
      pkg-config
      xdg-utils
      jq
      makeWrapper
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      wrapGAppsHook4
    ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    glib
    gtk3
    webkitgtk_4_1
    libayatana-appindicator
    cacert
    libXtst
  ];

  patchPhase = ''
    jq '.bundle.createUpdaterArtifacts = false' src-tauri/tauri.conf.json \
      > tmp.json && mv tmp.json src-tauri/tauri.conf.json
  '';

  preBuild = ''
    export NODE_EXTRA_CA_CERTS=${cacert}/etc/ssl/certs/ca-bundle.crt
    export HOME=$(mktemp -d)
    pnpm install --frozen-lockfile
    pnpm run build:icon
    pnpm run build:vite
  '';

  installPhase = ''
    install -Dm755 target/x86_64-unknown-linux-gnu/release/bongo-cat $out/libexec/bongocat
    install -Dm644 src-tauri/BongoCat.desktop $out/share/applications/BongoCat.desktop

    mkdir -p $out/dist
    cp -r dist/* $out/dist/

    mkdir -p $out/usr/lib/BongoCat/assets
    cp -r src-tauri/assets/* $out/usr/lib/BongoCat/assets/

    makeWrapper $out/libexec/bongocat $out/bin/bongocat \
      --set APPDIR $out \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath [ libayatana-appindicator ]}:$LD_LIBRARY_PATH
  '';

  meta = {
    description = "Desktop mascot app featuring animated cat drummer";
    homepage = "https://github.com/ayangweb/BongoCat";
    mainProgram = "bongocat";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
