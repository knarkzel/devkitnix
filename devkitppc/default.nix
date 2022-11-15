{pkgs ? import <nixpkgs> {}}:
with pkgs; rec {
  devkitppc-img = dockerTools.pullImage {
    imageName = "devkitpro/devkitppc";
    imageDigest = "sha256:77ed88cb417e057fa805e12a8ce1eab8865fe35a761cde7be00315d5c6cba288";
    sha256 = "LLFLDSPJ/tCRBLj0f9q34b5GVHnHudFCgkb7ppMm8VI=";
    finalImageName = "devkitpro/devkitppc";
    finalImageTag = "20200704";
  };

  # based on <nixpkgs/nixos/modules/virtualisation/docker-preloader.nix>
  extractDocker = image: dir:
    pkgs.vmTools.runInLinuxVM (
      pkgs.runCommand "docker-preload-image" {
        buildInputs = [
          docker
          e2fsprogs
          utillinux
          curl
          kmod
        ];
        memSize = 8 * 1024;
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
        docker run ${image.destNameTag} tar -C '${toString dir}' -c . | tar -xv --no-same-owner -C $out || true

        echo end
        kill %1
      ''
    );

  devkitpro = stdenv.mkDerivation {
    name = "devkitpro";
    src = extractDocker devkitppc-img "/opt/devkitpro";
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
