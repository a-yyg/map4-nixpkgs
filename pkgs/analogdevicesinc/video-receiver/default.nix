{ buildRosPackage
, ament-cmake
, ament-lint-auto
, ament-lint-common
, rclcpp
, rclcpp-components
, cv-bridge
, sensor-msgs
, pkg-config
}:
buildRosPackage rec {
  name = "video-receiver";
  src =
    let
      src' = builtins.fetchGit {
        url = "https://github.com/analogdevicesinc/gmsl.git";
        ref = "ros_rtp";
        rev = "5e65a2f2f5011f98432a22a6a59ef3cb304ea69a";
      };
    in "${src'}/ros_ws/src/video_receiver";

  buildType = "ament_cmake";
  buildInputs = [
    ament-cmake
    ament-lint-auto
    rclcpp
    cv-bridge
    pkg-config
  ];
  nativeBuildInputs = buildInputs;
  checkInputs = [ ament-lint-common ];
  propagatedBuildInputs = [
    sensor-msgs
  ];
}
