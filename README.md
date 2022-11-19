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

## Minimal example

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    devkitnix = {
      url = "github:knarkzel/devkitnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    devkitnix,
  }: let
    pkgs = import nixpkgs {system = "x86_64-linux";};
    devkitA64 = devkitnix.packages.x86_64-linux.devkitA64;
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = [
        devkitA64
      ];
      shellHook = ''
        export DEVKITPRO=${devkitA64}
      '';
    };
  };
}
```

For more example usage of `devkitnix`, see the [switch example](https://github.com/knarkzel/switch).
