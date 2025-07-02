{
  lib,
  buildGo124Module,
  fetchFromGitHub,
  pnpm_9,
  nodejs,
  go_1_24,
  git,
  cacert,
  nixosTests,
}:
let
  pname = "homebox";
  version = "0.20.1";
  src = fetchFromGitHub {
    owner = "sysadminsmedia";
    repo = "homebox";
    rev = "v${version}";
    hash = "sha256-QP9Tp9/ooRDVuP228cOqR8LAaSkrr9dumrw7Y9wZ51s=";
  };
in
buildGo124Module {
  inherit pname version src;

  vendorHash = "sha256-GTSFpfql0ebXtZC3LeIZo8VbCZdsbemNK5EarDTRAf0=";
  modRoot = "backend";
  # the goModules derivation inherits our buildInputs and buildPhases
  # Since we do pnpm thing in those it fails if we don't explicitly remove them
  overrideModAttrs = _: {
    nativeBuildInputs = [
      go_1_24
      git
      cacert
    ];
    preBuild = "";
  };

  pnpmDeps = pnpm_9.fetchDeps {
    inherit pname version;
    src = "${src}/frontend";
    hash = "sha256-gHQ8Evo31SFmnBHtLDY5j5zZwwVS4fmkT+9VHZJWhfs=";
  };
  pnpmRoot = "../frontend";

  env.NUXT_TELEMETRY_DISABLED = 1;

  preBuild = ''
    pushd ../frontend

    pnpm build

    popd

    mkdir -p ./app/api/static/public
    cp -r ../frontend/.output/public/* ./app/api/static/public
  '';

  nativeBuildInputs = [
    pnpm_9
    pnpm_9.configHook
    nodejs
  ];

  env.CGO_ENABLED = 0;
  doCheck = false;

  tags = [
    "nodynamic"
  ];

  ldflags = [
    "-s"
    "-w"
    "-extldflags=-static"
    "-X main.version=${version}"
    "-X main.commit=${version}"
  ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r $GOPATH/bin/api $out/bin/

    runHook postInstall
  '';

  passthru = {
    tests = {
      inherit (nixosTests) homebox;
    };
  };

  meta = {
    mainProgram = "api";
    homepage = "https://homebox.software/";
    description = "Inventory and organization system built for the Home User";
    maintainers = with lib.maintainers; [ patrickdag ];
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
  };
}
