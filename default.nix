let srcs = import ./nix/srcs.nix; in

{ pkgs ? import srcs.makerpkgs { inherit dapptoolsOverrides; }
, dapptoolsOverrides ? {}
, doCheck ? false
, githubAuthToken ? null
}: with pkgs;

let
  inherit (builtins) replaceStrings;
  inherit (lib) mapAttrs optionalAttrs id;
  # Get contract dependencies from lock file
  inherit (callPackage ./dapp2.nix {}) specs packageSpecs package;
  inherit (specs.this) deps;
  optinalFunc = x: fn: if x then fn else id;

  # Update GitHub repo URLs and add a auth token for private repos
  addGithubToken = spec: spec // (let
    url = replaceStrings
      [ "https://github.com" ]
      [ "https://${githubAuthToken}@github.com" ]
      spec.repo.url;
  in rec {
    repo = spec.repo // { inherit url; };
  });

  # Recursively add GitHub auth token to spec
  recAddGithubToken = spec: addGithubToken (spec // {
    deps = mapAttrs (_: recAddGithubToken) spec.deps;
  });

  # Create derivations from lock file data
  packages = packageSpecs (mapAttrs (_: spec:
    (optinalFunc (! isNull githubAuthToken) recAddGithubToken)
    (
      if spec == deps.ilk-registry
      then
        (spec // {
          inherit doCheck;
          name = "ilk-registry-0_6_7-optimized";
          solc = solc-versions.solc_0_6_7;
          solcFlags = "--optimize";
        })
      else
        (
          if spec == deps.dss-proxy-actions
          then
            (spec // {
              inherit doCheck;
              solc = solc-versions.solc_0_5_12;
              name = "dss-proxy-actions-optimized";
              solcFlags = "--optimize";
            })
          else
            (spec // {
              inherit doCheck;
              solc = solc-versions.solc_0_5_12;
            })
        )
    )
  ) deps);

  dss-deploy-optimized = package (deps.dss-deploy // {
    inherit doCheck;
    name = "dss-deploy-optimized";
    solc = solc-versions.solc_0_5_12;
    solcFlags = "--optimize";
  });

in makerScriptPackage {
  name = "dss-deploy-scripts";

  # Specify files to add to build environment
  src = lib.sourceByRegex ./. [
    "bin" "bin/.*"
    "lib" "lib/.*"
    "libexec" "libexec/.*"
    "config" "config/.*"
  ];

  solidityPackages =
    (builtins.attrValues packages)
    ++ [ dss-deploy-optimized ];
}
