{
  description = "oasis-core-tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    flake-utils,
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        LIBCLANG_PATH = "${pkgs.llvmPackages_11.libclang.lib}/lib";
        rust_toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain;

        mkPkg = {
          pname,
          version,
          cargoSha256,
          buildAndTestSubdir,
        }:
          pkgs.rustPlatform.buildRustPackage {
            inherit LIBCLANG_PATH rust_toolchain;

            pname = pname;
            version = version;

            src = builtins.path {
              path = ./.;
              name = "${pname}-${version}";
            };

            cargoSha256 = cargoSha256;
            buildAndTestSubdir = buildAndTestSubdir;

            nativeBuildInputs = with pkgs; [
              clang_11
              llvmPackages_11.libclang.lib
              rust_toolchain
            ];
          };

        # tests pkgs
        test-runtime-benchmarking = {
          pname = "test-runtime-benchmarking";
          version = "0.1.0";
          cargoSha256 = "sha256-lD/J3gld2SKQn+HGP5HLyjdHpKAC4XyUtVmbqZZT908=";
          buildAndTestSubdir = "./tests/runtimes/benchmarking";
        };

        test-runtime-simple-consensus = {
          pname = "test-runtime-simple-consensus";
          version = "0.1.0";
          cargoSha256 = "sha256-y62hFHBEC+El1CW5jHzvsBNCVwjkEvyzTwc4gZOBBY8=";
          buildAndTestSubdir = "./tests/runtimes/simple-consensus";
        };

        test-runtime-simple-contracts = {
          pname = "test-runtime-simple-contracts";
          version = "0.1.0";
          cargoSha256 = "sha256-MX/j1IIOQyryZKEDHwgJzLupWtNiM3FhFxhn1DPhpbk=";
          buildAndTestSubdir = "./tests/runtimes/simple-contracts";
        };

        test-runtime-simple-evm = {
          pname = "test-runtime-simple-evm";
          version = "0.1.0";
          cargoSha256 = "sha256-ZWo62j+hZDiEFrVnMsOOdqEfTl3evOD+jqgCSMDycRI=";
          buildAndTestSubdir = "./tests/runtimes/simple-evm";
        };

        test-runtime-simple-keyvalue = {
          pname = "test-runtime-simple-keyvalue";
          version = "0.1.0";
          cargoSha256 = "sha256-nA77+U/Pt5a1dNM70wkO6m+OCbfyM/jLSEG/swGs24U=";
          buildAndTestSubdir = "./tests/runtimes/simple-keyvalue";
        };

        # FIXME: no output
        runtime-sdk = {
          pname = "oasis-runtime-sdk";
          version = "0.1.0";
          cargoSha256 = "sha256-aQ2T77f2FZIE705jKqWY2p5bitHUsSd60vm7Q2o8FGU=";
          buildAndTestSubdir = "./runtime-sdk";
        };

        # FIXME: must compile for wasm ... ?
        runtime-sdk-contracts = {
          pname = "oasis-runtime-sdk-contracts";
          version = "0.1.0";
          cargoSha256 = "sha256-EcLuIpmZovN5as7XI6puwblUXCkMf1YgEcRKmeQs7Dg=";
          buildAndTestSubdir = "./runtime-sdk/modules/contracts";
        };

        # FIXME: no output
        runtime-sdk-macros = {
          pname = "oasis-runtime-sdk-macros";
          version = "0.1.0";
          cargoSha256 = "sha256-SGlvqsag9d3lG84CIKShPMorNv1tIdpurzz64gHG52A=";
          buildAndTestSubdir = "./runtime-sdk-macros";
        };

        # FIXME: no output
        contract-sdk-crypto = {
          pname = "oasis-contract-sdk-crypto";
          version = "0.1.0";
          cargoSha256 = "sha256-NiKA0clJL0d3xWkdW2/KLXg+TVpxmrR//OWnRbQfbK8=";
          buildAndTestSubdir = "./contract-sdk/crypto";
        };

        # FIXME: no output
        contract-sdk-types = {
          pname = "oasis-contract-sdk-types";
          version = "0.1.0";
          cargoSha256 = "sha256-EUpLy/EHXTOQwW+UaAEnqoVbvV4xp7qLm7dBLqMIa/M=";
          buildAndTestSubdir = "./contract-sdk/types";
        };
      in
        with pkgs; {
          packages.test-runtime-benchmarking = mkPkg test-runtime-benchmarking;
          packages.test-runtime-simple-consensus = mkPkg test-runtime-simple-consensus;
          packages.test-runtime-simple-contracts = mkPkg test-runtime-simple-contracts;
          packages.test-runtime-simple-evm = mkPkg test-runtime-simple-evm;
          packages.test-runtime-simple-keyvalue = mkPkg test-runtime-simple-keyvalue;
          packages.runtime-sdk = mkPkg runtime-sdk;
          packages.runtime-sdk-contracts = mkPkg runtime-sdk-contracts;
          packages.runtime-sdk-macros = mkPkg runtime-sdk-macros;
          packages.contract-sdk-crypto = mkPkg contract-sdk-crypto;
          packages.contract-sdk-types = mkPkg contract-sdk-types;

          defaultPackage = self.packages.${system}.test-runtime-simple-consensus;

          devShell = mkShell {
            inherit LIBCLANG_PATH rust_toolchain;

            buildInputs = [
              clang_11
              exa
              fd
              gcc
              gcc_multi
              libseccomp
              llvmPackages_11.libclang.lib
              openssl
              pkg-config
              protobuf
              rust_toolchain
              unixtools.whereis
              which
              b2sum
            ];

            shellHook = ''
              alias ls=exa
              alias find=fd
              export RUST_BACKTRACE=1
            '';
          };
        }
    );
}
