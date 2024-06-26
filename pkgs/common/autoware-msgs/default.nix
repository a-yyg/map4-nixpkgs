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
}:
let
  mainSrc = fetchFromGitHub {
    owner = "autowarefoundation";
    repo = "autoware_msgs";
    rev = "main";
    sha256 = "sha256-OgCwS3pOGKCZhaRhH7nurNI+mHmGelTtpDGMAcDS1Pk=";
  };
  buildM4Pkg = {name, ...}@args: buildRosPackage {
    name = name;

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
  pkg = pkg-name: deps:
    lib.attrsets.nameValuePair pkg-name (buildM4Pkg { name = (lib.strings.concatStringsSep "_" (lib.strings.splitString "-" pkg-name)); deps = deps; });
  m4pkg = msg-name: pkg "autoware-${msg-name}-msgs";
in lib.attrsets.listToAttrs [
  (m4pkg "common" [])
  (m4pkg "control" [])
  (m4pkg "localization" [])
  (m4pkg "map" [])
  (m4pkg "perception" [])
  (m4pkg "planning" [])
  (m4pkg "sensing" [])
  (m4pkg "system" [])
  (m4pkg "vehicle" [])
]
