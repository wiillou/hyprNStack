{
  description = "Hyprland plugin for N-stack tiling layout";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.hyprland.url = "github:hyprwm/Hyprland";

  outputs = { self, nixpkgs, hyprland }:
    let
      # Helper function to create packages for each system
      withPkgsFor = fn: nixpkgs.lib.genAttrs (builtins.attrNames hyprland.packages) (system: fn system nixpkgs.legacyPackages.${system});
      nstackLayout = withPkgsFor (system: pkgs: pkgs.gcc13Stdenv.mkDerivation {
        pname = "nstackLayoutPlugin";
        version = "1.0.0";
        src = ./.;
       
        inherit (hyprland.packages.${system}.hyprland) nativeBuildInputs;

        buildInputs = [ hyprland.packages.${system}.hyprland ] ++ hyprland.packages.${system}.hyprland.buildInputs;

        # Skip meson phases
        configurePhase = "true";
        mesonConfigurePhase  = "true";
        mesonBuildPhase = "true";
        mesonInstallPhase = "true";

        buildPhase = ''
          make all
        '';

        installPhase = ''
          mkdir -p $out/lib
          cp nstackLayoutPlugin.so $out/lib/libnstackLayoutPlugin.so
        '';

        meta = with pkgs.lib; {
          homepage = "Hyprland plugin for N-stack tiling layout";
          description = "Hyprland plugin for N-stack tiling layout";
          platforms = platforms.linux;
        };
      });
    in
    {
      packages = withPkgsFor (system: pkgs: rec {
        hyprNStack = nstackLayout.${system};
        default = hyprNStack;
      });

      devShells = withPkgsFor (system: pkgs: {
        default = pkgs.mkShell.override { stdenv = pkgs.gcc13Stdenv; } {
          name = "nstackLayoutPlugin";
          buildInputs = [ hyprland.packages.${system}.hyprland ];
          inputsFrom = [ hyprland.packages.${system}.hyprland ];
        };
      });
    };
}
