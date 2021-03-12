{
  description = "A free EDA software to develop printed circuit boards";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = "github:numtide/flake-utils";
    horizon = {
      url = "github:horizon-eda/horizon";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    let
      systems = [ "x86_64-linux" ];
    in
      flake-utils.lib.eachSystem systems ( system:
        let pkgs = nixpkgs.legacyPackages.${system}; in rec {
          packages = {
            horizon-eda = pkgs.stdenv.mkDerivation {
              pname = "horizon-eda";
              version = "1.4.0";

              src = inputs.horizon;

              buildInputs = [
                pkgs.cppzmq
                pkgs.curl
                pkgs.epoxy
                pkgs.glm
                pkgs.gnome3.gtkmm
                pkgs.libgit2
                pkgs.librsvg
                pkgs.libuuid
                pkgs.libzip
                pkgs.opencascade
                pkgs.podofo
                pkgs.python3
                pkgs.sqlite
                pkgs.zeromq
              ];

              nativeBuildInputs = [
                pkgs.boost.dev
                pkgs.pkg-config
                pkgs.wrapGAppsHook
              ];

              CASROOT = pkgs.opencascade;

              installFlags = [
                "INSTALL=${pkgs.coreutils}/bin/install"
                "DESTDIR=$(out)"
                "PREFIX="
              ];

              enableParallelBuilding = true;
            };

            nixpkgs-in = pkgs;
          };

          defaultPackage = packages.horizon-eda;
          defaultApp = {
            type = "app";
            program = defaultPackage + "/bin/horizon-eda";
          };
        }
      );
}
