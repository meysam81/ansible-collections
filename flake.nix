{
  description = "meysam81.general Ansible collection dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Python (for ansible ecosystem via venv)
              python3
              python3Packages.pip
              python3Packages.virtualenv

              # Task runner
              just

              # YAML processor (used in Justfile)
              yq-go

              # Linters
              ruff
              actionlint
              prek

              # Security
              #trivy

              # Changelog
              git-cliff

              # Docker client (daemon is host-provided)
              docker-client
            ];

            shellHook = ''
              if [ ! -d .venv ]; then
                echo "Creating Python virtualenv..."
                python3 -m venv .venv
              fi
              source .venv/bin/activate
              pip install -q -r requirements.txt 2>/dev/null
            '';
          };
        }
      );
    };
}
