{ lib
, fetchFromGitHub
, python3
}:

let
  pname = "mealie-mcp-server";
  version = "0-unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "rldiao";
    repo = "mealie-mcp-server";
    rev = "f7a2a5e21e68e223629393a5ad16f55dca6ea577";
    hash = "sha256-yqvFRriN3JvorPoVTJXDYEuAOsdWe9X5vDMN+a/47Ug=";
  };

in
python3.pkgs.buildPythonPackage {
  inherit pname version src;
  
  format = "other";
  dontUnpack = false;

  propagatedBuildInputs = with python3.pkgs; [
    httpx
    mcp
    pydantic
    python-dotenv
  ];

  installPhase = ''
    runHook preInstall

    # Copy source code to site-packages
    mkdir -p $out/${python3.sitePackages}/mealie_mcp_server
    cp -r src/* $out/${python3.sitePackages}/mealie_mcp_server/

    # Create wrapper script
    mkdir -p $out/bin
    cat > $out/bin/mealie-mcp-server << 'WRAPPER'
    #!${python3}/bin/python
    import sys, os
    sys.path.insert(0, os.path.join(os.path.dirname(os.path.realpath(__file__)),
        '..', '${python3.sitePackages}', 'mealie_mcp_server'))
    import server
    server.mcp.run(transport='stdio')
    WRAPPER
    chmod +x $out/bin/mealie-mcp-server

    runHook postInstall
  '';

  meta = with lib; {
    description = "MCP server that exposes Mealie APIs to MCP clients";
    homepage = "https://github.com/rldiao/mealie-mcp-server";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
