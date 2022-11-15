let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/e3583ad6e533a9d8dd78f90bfa93812d390ea187.tar.gz") {};
  image = pkgs.dockerTools.pullImage {
    imageName = "devkitpro/devkitppc";
    imageDigest = "sha256:d88e21c1a7b5f8070ba7a15aa892e395f118ded9803b0f8223a3d29ba279fff3";
    sha256 = "nVtz/9mbYveKbvTMj/39EzND7qiLkjBHfqSOgT6SBUY=";
    finalImageName = "devkitpro/devkitppc";
    finalImageTag = "20220821";
  };
in {
  devkitPPC = pkgs.stdenv.mkDerivation {
    name = "devkitPPC";
    src = import ./extract-docker.nix pkgs image;
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [
      pkgs.stdenv.cc.cc
      pkgs.ncurses5
      pkgs.expat
      pkgs.xz
    ];
    buildPhase = "true";
    installPhase = ''
      mkdir -p $out
      cp -r $src/{devkitPPC,libogc,portlibs,tools,wut} $out
      rm -rf $out/pacman
    '';
  };
}
