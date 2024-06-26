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
  pname = "t4-tensorrt-common";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "tier4";
    repo = "tensorrt_common";
    rev = "main";
    sha256 = "sha256-baJtn+KG4rRvd77/WPkF1pzw/ZSEI8b/gnZB2f5af34=";
  };

  buildType = "ament_cmake";
  buildInputs = [ ament-cmake-auto ];
  # buildInputs = [ ament-cmake-auto cudnn-cmake-module cudatoolkit ];
  checkInputs = [ ament-lint-auto ament-lint-common ];
  propagatedBuildInputs = [ rclcpp cudnn-cmake-module tensorrt-cmake-module tensorrt cudnn cudatoolkit ];
  nativeBuildInputs = [ ament-cmake-auto ];

  meta = {
    description = "Interfaces between core Autoware.Auto components";
    license = with lib.licenses; [ asl20 ];
  };
}
