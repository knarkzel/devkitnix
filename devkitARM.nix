let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/e3583ad6e533a9d8dd78f90bfa93812d390ea187.tar.gz") {};
  image = pkgs.dockerTools.pullImage {
    imageName = "devkitpro/devkitarm";
    imageDigest = "sha256:695d1eb865ca4b908b1f5c4de777b9eef0f927680f0c0654b07721f1df908606";
    sha256 = "U2Xkt4IYUeU00w/FzlvySzG5lFL2R7kN8sjxL0EEKD4=";
    finalImageName = "devkitpro/devkitarm";
    finalImageTag = "20221115";
  };
in {
  devkitARM = pkgs.stdenv.mkDerivation {
    name = "devkitARM";
    src = import ./extract-docker.nix pkgs image;
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [
      pkgs.stdenv.cc.cc
      pkgs.ncurses6
      pkgs.zsnes
    ];
    buildPhase = "true";
    installPhase = ''
      mkdir -p $out
      cp -r $src/{devkitARM,libgba,libnds,libctru,libmirko,liborcus,portlibs,tools} $out
      rm -rf $out/pacman
    '';
  };
}
