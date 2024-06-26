{ lib, buildRosPackage, fetchFromGitHub, action-msgs, ament-cmake-auto, ament-lint-auto, ament-lint-common, geometry-msgs, rosidl-default-generators, rosidl-default-runtime, sensor-msgs, std-msgs }:
let
  mainSrc = fetchFromGitHub {
    owner = "MapIV";
    repo = "autoware_auto_msgs";
    rev = "tier4/main";
    sha256 = "sha256-jaoDOPw0QRY1YC4i8P9NHdTidomSzkVmogJro406fiM=";
  };
  buildM4Pkg = {name, ...}@args: buildRosPackage {
    name = name;
    # pname = name;
    # version = "0.0.0";

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
in rec {
  autoware-auto-control-msgs = buildM4Pkg {
    name = "autoware_auto_control_msgs";
  };
  autoware-auto-geometry-msgs = buildM4Pkg {
    name = "autoware_auto_geometry_msgs";
  };
  autoware-auto-mapping-msgs = buildM4Pkg {
    name = "autoware_auto_mapping_msgs";
  };
  autoware-auto-msgs = buildM4Pkg {
    name = "autoware_auto_msgs";
  };
  autoware-auto-perception-msgs = buildM4Pkg {
    name = "autoware_auto_perception_msgs";
    deps = [ autoware-auto-geometry-msgs ];
  };
  autoware-auto-planning-msgs = buildM4Pkg {
    name = "autoware_auto_planning_msgs";
  };
  autoware-auto-system-msgs = buildM4Pkg {
    name = "autoware_auto_system_msgs";
  };
  autoware-auto-vehicle-msgs = buildM4Pkg {
    name = "autoware_auto_vehicle_msgs";
  };
}

