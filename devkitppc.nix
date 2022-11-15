let
  pkgs = import <nixpkgs> {};
  devkitppc-img = pkgs.dockerTools.pullImage {
    imageName = "devkitpro/devkitppc";
    imageDigest = "sha256:d88e21c1a7b5f8070ba7a15aa892e395f118ded9803b0f8223a3d29ba279fff3";
    sha256 = "nVtz/9mbYveKbvTMj/39EzND7qiLkjBHfqSOgT6SBUY=";
    finalImageName = "devkitpro/devkitppc";
    finalImageTag = "20220821";
  };
in {
  devkitppc = pkgs.stdenv.mkDerivation {
    name = "devkitppc";
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
      pkgs.xz
    ];
    buildPhase = "true";
    installPhase = ''
      mkdir -p $out
      cp -r $src/{devkitPPC,libogc,examples,portlibs,tools,wut} $out
      rm -rf $out/pacman
    '';
  };
}
