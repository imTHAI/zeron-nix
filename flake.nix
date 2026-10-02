{
  # Local test harness for pkgs/by-name/ze/zeron before upstreaming to nixpkgs.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # NixOS/nixpkgs#569116 (onnxruntime 1.27.1 -> 1.30.0). zeron's ort-sys
    # needs the 1.28 C API at least; drop once the PR lands in unstable.
    nixpkgs-onnxruntime = {
      url = "github:copumpkin/nixpkgs/f874ecfd4bb98fbab976cac2713b89a2944bd734";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, nixpkgs-onnxruntime, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAll (pkgs: rec {
        # doCheck: on x86_64-linux the PR fails one OpenVINO EP test
        # (OVEPOVIRModelsExportEPContextTests.ExportEpCtxFromOVIRModel/embed_off),
        # unrelated to the CPU provider zeron uses. Scoped to that platform so
        # the darwin build keeps hitting the already-built derivation.
        onnxruntime =
          let
            drv = pkgs.callPackage "${nixpkgs-onnxruntime}/pkgs/by-name/on/onnxruntime/package.nix" { };
          in
          if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then
            drv.overrideAttrs { doCheck = false; }
          else
            drv;
        zeron = pkgs.callPackage ./pkgs/by-name/ze/zeron/package.nix {
          inherit onnxruntime;
          # Mirrors the maintainers/maintainer-list.nix entry the nixpkgs PR adds;
          # drop once it is merged.
          lib = pkgs.lib.extend (
            _: prev: {
              maintainers = prev.maintainers // {
                imTHAI = {
                  github = "imTHAI";
                  githubId = 36070606;
                };
              };
            }
          );
        };
        default = zeron;
      });
    };
}
