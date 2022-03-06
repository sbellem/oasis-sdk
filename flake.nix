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
      in
        with pkgs; {
          packages.test-runtime-simple-consensus = rustPlatform.buildRustPackage rec {
            inherit LIBCLANG_PATH rust_toolchain;

            pname = "test-runtime-simple-consensus";
            version = "0.1.0";

            src = builtins.path {
              path = ./.;
              name = "${pname}-${version}";
            };

            cargoSha256 = "sha256-y62hFHBEC+El1CW5jHzvsBNCVwjkEvyzTwc4gZOBBY8=";
            buildAndTestSubdir = "./tests/runtimes/simple-consensus";

            nativeBuildInputs = with pkgs; [
              clang_11
              llvmPackages_11.libclang.lib
              rust_toolchain
            ];
          };

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
