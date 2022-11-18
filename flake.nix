{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    pkgs = import nixpkgs {system = "x86_64-linux";};
    imageA64 = pkgs.dockerTools.pullImage {
      imageName = "devkitpro/devkita64";
      imageDigest = "sha256:70db4c954eea43be5f1bc64c8882154126c99f47927ecb1e6b27fa18004fc961";
      sha256 = "a05LU5jF5KxQdqWJv+4b3EBRlVCZjBGx69WpFL57wP4=";
      finalImageName = "devkitpro/devkita64";
      finalImageTag = "20221113";
    };
    imageARM = pkgs.dockerTools.pullImage {
      imageName = "devkitpro/devkitarm";
      imageDigest = "sha256:695d1eb865ca4b908b1f5c4de777b9eef0f927680f0c0654b07721f1df908606";
      sha256 = "U2Xkt4IYUeU00w/FzlvySzG5lFL2R7kN8sjxL0EEKD4=";
      finalImageName = "devkitpro/devkitarm";
      finalImageTag = "20221115";
    };
    imagePPC = pkgs.dockerTools.pullImage {
      imageName = "devkitpro/devkitppc";
      imageDigest = "sha256:d88e21c1a7b5f8070ba7a15aa892e395f118ded9803b0f8223a3d29ba279fff3";
      sha256 = "nVtz/9mbYveKbvTMj/39EzND7qiLkjBHfqSOgT6SBUY=";
      finalImageName = "devkitpro/devkitppc";
      finalImageTag = "20220821";
    };
    extractDocker = image:
      pkgs.vmTools.runInLinuxVM (
        pkgs.runCommand "docker-preload-image" {
          memSize = 10 * 1024;
          buildInputs = [
            pkgs.curl
            pkgs.kmod
            pkgs.docker
            pkgs.e2fsprogs
            pkgs.utillinux
          ];
        }
        ''
          modprobe overlay

          # from https://github.com/tianon/cgroupfs-mount/blob/master/cgroupfs-mount
          mount -t tmpfs -o uid=0,gid=0,mode=0755 cgroup /sys/fs/cgroup
          cd /sys/fs/cgroup
          for sys in $(awk '!/^#/ { if ($4 == 1) print $1 }' /proc/cgroups); do
            mkdir -p $sys
            if ! mountpoint -q $sys; then
              if ! mount -n -t cgroup -o $sys cgroup $sys; then
                rmdir $sys || true
              fi
            fi
          done

          dockerd -H tcp://127.0.0.1:5555 -H unix:///var/run/docker.sock &

          until $(curl --output /dev/null --silent --connect-timeout 2 http://127.0.0.1:5555); do
            printf '.'
            sleep 1
          done

          echo load image
          docker load -i ${image}

          echo run image
          docker run ${image.destNameTag} tar -C /opt/devkitpro -c . | tar -xv --no-same-owner -C $out || true

          echo end
          kill %1
        ''
      );
  in {
    packages.x86_64-linux.devkitA64 = pkgs.stdenv.mkDerivation {
      name = "devkitA64";
      src = extractDocker imageA64;
      nativeBuildInputs = [
        pkgs.autoPatchelfHook
      ];
      buildInputs = [
        pkgs.stdenv.cc.cc
        pkgs.ncurses6
        pkgs.zsnes
      ];
      buildPhase = "true";
      installPhase = ''
        mkdir -p $out
        cp -r $src/{devkitA64,libnx,portlibs,tools} $out
        rm -rf $out/pacman
      '';
    };

    packages.x86_64-linux.devkitARM = pkgs.stdenv.mkDerivation {
      name = "devkitARM";
      src = extractDocker imageARM;
      nativeBuildInputs = [pkgs.autoPatchelfHook];
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

    packages.x86_64-linux.devkitPPC = pkgs.stdenv.mkDerivation {
      name = "devkitPPC";
      src = extractDocker imagePPC;
      nativeBuildInputs = [pkgs.autoPatchelfHook];
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
  };
}
