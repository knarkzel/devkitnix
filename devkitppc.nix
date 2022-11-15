{pkgs ? import <nixpkgs> {}}:
with pkgs; rec {
  devkitppc-img = dockerTools.pullImage {
    imageName = "devkitpro/devkitppc";
    imageDigest = "sha256:77ed88cb417e057fa805e12a8ce1eab8865fe35a761cde7be00315d5c6cba288";
    sha256 = "LLFLDSPJ/tCRBLj0f9q34b5GVHnHudFCgkb7ppMm8VI=";
    finalImageName = "devkitpro/devkitppc";
    finalImageTag = "20200704";
  };

  devkitpro = stdenv.mkDerivation {
    name = "devkitpro";
    src = import ./extract-docker.nix {
      image = devkitppc-img;
      directory = "/opt/devkitpro";
    };
    nativeBuildInputs = [
      autoPatchelfHook
    ];
    buildInputs = [
      stdenv.cc.cc
      openssl
      zlib
      libarchive
      ncurses5
      expat
      tlf
    ];
    buildPhase = "true";
    installPhase = ''
      mkdir -p $out
      cp -r $src/{devkitPPC,libogc,examples,portlibs,tools,wut} $out
      rm -rf $out/pacman
    '';
  };
}
