{
  inputs.nixpkgs.url = "nixpkgs/master";
  description = "sccache";

  outputs = { self, nixpkgs }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
        defaultPackage = forAllSystems (system:
        let
            pkgs = nixpkgsFor.${system};
        in
        with pkgs; pkgs.rustPlatform.buildRustPackage rec {
          version = "0.2.15";
          pname = "sccache";
          src = ./.;

          cargoSha256 = "1f42cqaqnjwi9k4ihqil6z2dqh5dnf76x54gk7mndzkrfg3rl573";

          nativeBuildInputs = [ pkg-config ];
          buildInputs = [ openssl ];

          # sccache-dist is only supported on x86_64 Linux machines.
          buildFeatures = lib.optionals (stdenv.system == "x86_64-linux") [ "dist-client" "dist-server" ];

          # Tests fail because of client server setup which is not possible inside the pure environment,
          # see https://github.com/mozilla/sccache/issues/460
          doCheck = false;

        });
    };

}
