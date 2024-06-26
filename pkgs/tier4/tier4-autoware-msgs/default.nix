# Copyright 2024 Open Source Robotics Foundation
# Distributed under the terms of the BSD license

{ lib
, buildRosPackage
, fetchFromGitHub
, action-msgs
, ament-cmake-auto
, ament-lint-auto
, ament-lint-common
, geometry-msgs
, rosidl-default-generators
, rosidl-default-runtime
, sensor-msgs
, std-msgs
, autoware-perception-msgs
}:
let
  mainSrc = fetchFromGitHub {
    owner = "tier4";
    repo = "tier4_autoware_msgs";
    rev = "tier4/universe";
    sha256 = "sha256-cMdD0iI4/i76XV4B5Yz3vDon41K1pAC7hA7tc2tp314=";
  };
  buildM4Pkg = {name, ...}@args: buildRosPackage {
    pname = "m4-${name}";
    version = "0.0.0";

    src = "${mainSrc}/${name}";

    buildType = "ament_cmake";
    buildInputs = [ ament-cmake-auto rosidl-default-generators ];
    checkInputs = [ ament-lint-auto ament-lint-common ];
    propagatedBuildInputs = [ action-msgs geometry-msgs rosidl-default-runtime sensor-msgs std-msgs ] ++ (args.deps or []);
    nativeBuildInputs = [ ament-cmake-auto ];

    meta = {
      description = "Interfaces between core Autoware.Auto components";
      license = with lib.licenses; [ asl20 ];
    };
  };
  m4pkg = pkg-name: deps:
    lib.attrsets.nameValuePair pkg-name (buildM4Pkg { name = (lib.strings.concatStringsSep "_" (lib.strings.splitString "-" pkg-name)); deps = deps; });
in lib.attrsets.listToAttrs [
  (m4pkg "tier4-perception-msgs" [ autoware-perception-msgs ])
]
