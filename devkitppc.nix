let
  pkgs = import <nixpkgs> {};
  devkitppc-img = pkgs.dockerTools.pullImage {
    imageName = "devkitpro/devkitppc";
    imageDigest = "sha256:77ed88cb417e057fa805e12a8ce1eab8865fe35a761cde7be00315d5c6cba288";
    sha256 = "LLFLDSPJ/tCRBLj0f9q34b5GVHnHudFCgkb7ppMm8VI=";
    finalImageName = "devkitpro/devkitppc";
    finalImageTag = "20200704";
  };
in {
  devkitpro = pkgs.stdenv.mkDerivation {
    name = "devkitpro";
    src = import ./extract-docker.nix {
      pkgs = pkgs;
      image = devkitppc-img;
      directory = "/opt/devkitpro";
    };
    nativeBuildInputs = [
      pkgs.autoPatchelfHook
    ];
    buildInputs = [
      pkgs.stdenv.cc.cc
      pkgs.ncurses5
      pkgs.expat
    ];
    buildPhase = "true";
    installPhase = ''
      mkdir -p $out
      cp -r $src/{devkitPPC,libogc,examples,portlibs,tools,wut} $out
      rm -rf $out/pacman
    '';
  };
}
