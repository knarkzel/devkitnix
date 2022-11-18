{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-22.05";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {};
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
    });
}
