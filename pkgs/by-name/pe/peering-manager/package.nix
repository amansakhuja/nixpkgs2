{
  python3,
  fetchFromGitHub,
  nixosTests,
  lib,

  plugins ? ps: [ ],
}:

python3.pkgs.buildPythonApplication rec {
  pname = "peering-manager";
  version = "1.9.4";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    tag = "v${version}";
    sha256 = "sha256-sSIe+qat9J0pTUXqA1u9EiYwBVG11Jsg6QldOTyUhBQ=";
  };

  format = "other";

  propagatedBuildInputs =
    with python3.pkgs;
    [
      django
      django-debug-toolbar
      django-filter
      django-postgresql-netfields
      django-prometheus
      django-redis
      django-rq
      django-tables2
      django-taggit
      djangorestframework
      drf-spectacular
      drf-spectacular-sidecar
      dulwich
      jinja2
      markdown
      napalm
      packaging
      psycopg2
      pyixapi
      pynetbox
      pyyaml
      requests
      social-auth-app-django
      tzdata
    ]
    ++ plugins python3.pkgs;

  buildPhase = ''
    runHook preBuild
    cp peering_manager/configuration{.example,}.py
    python3 manage.py collectstatic --no-input
    rm -f peering_manager/configuration.py
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt/peering-manager
    cp -r . $out/opt/peering-manager
    chmod +x $out/opt/peering-manager/manage.py
    makeWrapper $out/opt/peering-manager/manage.py $out/bin/peering-manager \
      --prefix PYTHONPATH : "$PYTHONPATH"
    runHook postInstall
  '';

  passthru = {
    # PYTHONPATH of all dependencies used by the package
    python = python3;
    pythonPath = python3.pkgs.makePythonPath propagatedBuildInputs;

    tests = {
      inherit (nixosTests) peering-manager;
    };
  };

  meta = with lib; {
    homepage = "https://peering-manager.net/";
    license = licenses.asl20;
    description = "BGP sessions management tool";
    mainProgram = "peering-manager";
    maintainers = teams.wdz.members;
    platforms = platforms.linux;
  };
}
