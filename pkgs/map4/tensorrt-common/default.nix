{ lib
, buildRosPackage
, fetchFromGitHub
, ament-cmake-auto
, ament-lint-auto
, ament-lint-common
, cudatoolkit
, tensorrt
, cudnn
, rclcpp
, tensorrt-cmake-module
, cudnn-cmake-module
}:
buildRosPackage {
  name = "m4-tensorrt_common";

  src = fetchFromGitHub {
    owner = "MapIV";
    repo = "tensorrt_common";
    rev = "main";
    sha256 = "sha256-OWzpIIWaDFA5BFfFZdmM7bwyC1uDYQ2Ul+m8qktcdck=";
  };

  buildType = "ament_cmake";
  buildInputs = [ ament-cmake-auto ];
  checkInputs = [ ament-lint-auto ament-lint-common ];
  propagatedBuildInputs = [ rclcpp cudnn-cmake-module tensorrt-cmake-module tensorrt cudnn cudatoolkit ];
  nativeBuildInputs = [ ament-cmake-auto ];

  meta = {
    description = "Interfaces between core Autoware.Auto components";
    license = with lib.licenses; [ asl20 ];
  };
}
