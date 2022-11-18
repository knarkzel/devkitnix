# devkitnix

Collection of devkitPro packages for Nix using flakes.
To build a toolchain like devkitPPC, use following:

```
nix build github:zig-homebrew/devkitnix#devkitPPC
```

## Toolchains

```
└───packages
    └───x86_64-linux
        ├───devkitA64: package 'devkitA64'
        ├───devkitARM: package 'devkitARM'
        └───devkitPPC: package 'devkitPPC'
```
