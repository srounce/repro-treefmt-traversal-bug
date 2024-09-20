{
  flake,
  inputs,
  pkgs,
  ...
}:
let
  treefmt-settings = {
    package = pkgs.treefmt2;

    projectRootFile = "flake.nix";

    programs.deadnix.enable = true;
    programs.nixfmt.enable = true;

    programs.shellcheck.enable = true;
    programs.shfmt.enable = true;

    settings.formatter.deadnix.pipeline = "nix";
    settings.formatter.deadnix.priority = 1;
    settings.formatter.nixfmt.pipeline = "nix";
    settings.formatter.nixfmt.priority = 2;

    settings.formatter.shellcheck.pipeline = "shell";
    settings.formatter.shellcheck.includes = [
      "*.sh"
      "*.envrc"
      "*.envrc.*"
      "bin/*"
    ];
    settings.formatter.shellcheck.priority = 1;
    settings.formatter.shfmt.pipeline = "shell";
    settings.formatter.shfmt.includes = [
      "*.sh"
      "*.envrc"
      "*.envrc.*"
      "bin/*"
    ];
    settings.formatter.shfmt.priority = 2;
  };

  formatter = inputs.treefmt-nix.lib.mkWrapper pkgs treefmt-settings;

  check =
    pkgs.runCommand "format-check"
      {
        nativeBuildInputs = [
          formatter
          pkgs.git
        ];

        # only check on Linux
        meta.platforms = pkgs.lib.platforms.linux;
      }
      ''
        export HOME=$NIX_BUILD_TOP/home

        # keep timestamps so that treefmt is able to detect mtime changes
        cp --no-preserve=mode --preserve=timestamps -r ${flake} source
        cd source
        git init --quiet
        git add .
        treefmt --no-cache
        if ! git diff --exit-code; then
          echo "-------------------------------"
          echo "aborting due to above changes ^"
          exit 1
        fi
        touch $out
      '';
in
formatter
// {
  meta = formatter.meta // {
    tests = {
      check = check;
    };
  };
}
