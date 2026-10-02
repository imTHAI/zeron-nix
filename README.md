# zeron-nix

Work-in-progress Nix package for [Zeron](https://github.com/zeronsh/zeron), meant to be upstreamed to nixpkgs as `pkgs/by-name/ze/zeron`.

```bash
nix build github:imTHAI/zeron-nix#zeron
```

Targets: `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`.

The flake temporarily takes `onnxruntime` from NixOS/nixpkgs#569116 (1.30.0), because Zeron's dictation needs the onnxruntime 1.28+ C API and nixpkgs unstable still ships 1.27.1.
