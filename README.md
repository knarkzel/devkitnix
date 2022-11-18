# devkitnix

Collection of devkitPro packages for Nix using flakes.

```
$ nix flake show github:knarkzel/devkitnix
└───packages
    └───x86_64-linux
        ├───devkitA64: package 'devkitA64'
        ├───devkitARM: package 'devkitARM'
        └───devkitPPC: package 'devkitPPC'
$ nix build github:knarkzel/devkitnix#devkitPPC
$ ls result
devkitPPC  libogc  portlibs  tools  wut
```

For example usage of `devkitnix`, see the [switch example](https://github.com/knarkzel/switch).
