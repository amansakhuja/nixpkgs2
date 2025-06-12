{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  cmake,
  ninja,
  # build-system
  hatchling,
  scikit-build-core,
  hatch-vcs,
  nanobind,
  # deps
  antlr4-python3-runtime,
  attrs,
  atopile-easyeda2kicad,
  black,
  case-converter,
  cookiecutter,
  dataclasses-json,
  deprecated,
  fastapi-github-oidc,
  freetype-py,
  gitpython,
  kicadcliwrapper,
  matplotlib,
  more-itertools,
  natsort,
  numpy,
  pathvalidate,
  pint,
  posthog,
  psutil,
  pydantic-settings,
  pygls,
  questionary,
  requests,
  rich,
  ruamel-yaml,
  ruff,
  semver,
  sexpdata,
  shapely,
  typer,
  urllib3,
  pythonOlder,

  # tests
  pytestCheckHook,
  pytest-xdist,
  pytest-timeout,
  hypothesis,
}:

buildPythonPackage rec {
  pname = "atopile";
  version = "0.8.2";
  pyproject = true;

  disabled = pythonOlder "3.12";

  src = fetchFromGitHub {
    owner = "atopile";
    repo = "atopile";
    tag = "v${version}";
    hash = "sha256-NnaPXNJAwLF9Q/5qqbZoz4nxfOIjnO5nefC7NnHZeWw=";
  };

  build-system = [
    hatchling
    scikit-build-core
    hatch-vcs
    nanobind
  ];

  dontUseCmakeConfigure = true; # skip cmake configure invocation

  nativeBuildInputs = [
    cmake
    ninja
  ];

  dependencies = [
    antlr4-python3-runtime
    attrs
    atopile-easyeda2kicad
    black # used as a dependency
    case-converter
    cookiecutter
    dataclasses-json
    deprecated
    fastapi-github-oidc
    freetype-py
    gitpython
    kicadcliwrapper
    matplotlib
    more-itertools
    natsort
    numpy
    pathvalidate
    pint
    posthog
    psutil
    pydantic-settings
    pygls
    questionary
    requests
    rich
    ruamel-yaml
    ruff
    semver
    sexpdata
    shapely
    typer
    urllib3
  ];

  pythonRelaxDeps = [
    "black"
    "rich"
    "psutil"
  ];

  pythonImportsCheck = [ "atopile" ];

  preCheck = ''
    # do not report worker logs to filee
    substituteInPlace test/conftest.py \
      --replace-fail "worker_id =" "worker_id = None #"

    substituteInPlace pyproject.toml \
      --replace-fail "--html=artifacts/test-report.html" "" \
      --replace-fail "--self-contained-html" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
    pytest-timeout
    hypothesis
  ];

  doCheck = false; # test are hanging

  meta = {
    description = "Design circuit boards with code";
    homepage = "https://atopile.io";
    downloadPage = "https://github.com/atopile/atopile";
    changelog = "https://github.com/atopile/atopile/releases/tag/${src.rev}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "ato";
  };
}
