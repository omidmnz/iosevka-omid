{
  description = "Iosevka - My Custom Variant";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      allSystems = flake-utils.lib.eachDefaultSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};

            iosevka-omid = pkgs.iosevka.override {
              set = "omid";
              privateBuildPlan = {
                family = "Iosevka Omid";
                spacing = "normal";
                serifs = "sans";
                export-glyph-names = true;
                ligations = {
                  inherits = "dlig";
                  enables = [ "tildeeq" ]; # NOTE: ~​= as not-equals
                };
                snapshotFeature.NWID = 0;
                variants = {
                  inherits = "ss05";
                  design = {
                    zero = "tall-slashed-cutout";
                    six = "open-contour";
                    ampersand = "upper-open";
                    dollar = "open-cap";
                  };
                };
              };
            };

            iosevka-term-omid = pkgs.iosevka.override {
              set = "term-omid";
              privateBuildPlan = {
                family = "Iosevka Term Omid";
                snapshotFamily = "Iosevka";
                spacing = "term";
                snapshotFeature.NWID = 1;
                export-glyph-names = true;
                variants = {
                  inherits = "ss05";
                  design = {
                    zero = "tall-slashed-cutout";
                    six = "open-contour";
                    ampersand = "upper-open";
                    dollar = "open-cap";
                  };
                };
              };
            };

            iosevka-etoile-omid = pkgs.iosevka.override {
              set = "etoile-omid";
              privateBuildPlan = {
                family = "Iosevka Etoile Omid";
                snapshotFamily = "Iosevka Etoile Omid";
                spacing = "quasi-proportional";
                serifs = "slab";
                export-glyph-names = true;
                snapshotFeature.NWID = 0;
                widths.normal = {
                  shape = 600;
                  menu = 5;
                  css = "normal";
                };
                variants = {
                  inherits = "ss05";
                  design = {
                    zero = "tall-slashed-cutout";
                    six = "open-contour";
                    guillemet = "curly";
                    ampersand = "closed";
                    dollar = "interrupted";
                    # From the default Etoile build
                    capital-w = "straight-flat-top-serifed";
                    f = "flat-hook-serifed";
                    j = "flat-hook-serifed";
                    t = "flat-hook";
                    w = "straight-flat-top-serifed";
                    at = "fourfold";
                    percent = "rings-continuous-slash";
                  };
                  italic = {
                    # From the default Etoile build
                    f = "flat-hook-tailed";
                    w = "straight-flat-top-motion-serifed";
                  };
                };
              };
            };

            iosevka-omid-nerd-font = let outDir = "$out/share/fonts/truetype/"; in
              pkgs.stdenv.mkDerivation {
                pname = "iosevka-omid-nerd-font";
                version = iosevka-omid.version;

                src = builtins.path { path = ./.; name = "iosevka-omid"; };

                buildInputs = [ pkgs.nerd-font-patcher pkgs.findutils ];

                configurePhase = "mkdir -p ${outDir}";
                buildPhase = ''
                  find ${iosevka-omid}/share/fonts/truetype/ -type f -print0 \
                    | xargs -P$NIX_BUILD_CORES -0 -I@@ nerd-font-patcher @@ --complete --careful --outputdir ${outDir}
                '';
                dontInstall = true;
              };

            iosevka-term-omid-nerd-font = let outDir = "$out/share/fonts/truetype/"; in
              pkgs.stdenv.mkDerivation {
                pname = "iosevka-term-omid-nerd-font";
                version = iosevka-term-omid.version;

                src = builtins.path { path = ./.; name = "iosevka-term-omid"; };

                buildInputs = [ pkgs.nerd-font-patcher pkgs.findutils ];

                configurePhase = "mkdir -p ${outDir}";
                buildPhase = ''
                  find ${iosevka-term-omid}/share/fonts/truetype/ -type f -print0 \
                    | xargs -P$NIX_BUILD_CORES -0 -I@@ nerd-font-patcher @@ --complete --careful --outputdir ${outDir}
                '';
                dontInstall = true;
              };

            packages = {
              iosevka-omid = iosevka-omid;
              iosevka-omid-nerd-font = iosevka-omid-nerd-font;
              iosevka-term-omid = iosevka-term-omid;
              iosevka-term-omid-nerd-font = iosevka-term-omid-nerd-font;
              iosevka-etoile-omid = iosevka-etoile-omid;
            };
          in
          {
            inherit packages;
            defaultPackage = iosevka-omid;
          }
        );
    in
    {
      packages = allSystems.packages;
      defaultPackage = allSystems.defaultPackage;
      overlay = final: prev: {
        iosevka-omid = allSystems.packages.${final.system}.iosevka-omid;
        iosevka-term-omid = allSystems.packages.${final.system}.iosevka-term-omid;
        iosevka-omid-nerd-font = allSystems.packages.${final.system}.iosevka-omid-nerd-font;
        iosevka-term-omid-nerd-font = allSystems.packages.${final.system}.iosevka-term-omid-nerd-font;
        iosevka-etoile-omid = allSystems.packages.${final.system}.iosevka-etoile-omid;
      };
    };
}
