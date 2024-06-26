{ buildRosPackage
, ament-cmake
, ament-cmake-core
, ament-cmake-auto
, ament-lint-auto
, ament-lint-common
, rclcpp-components
, image-transport
, cv-bridge
, opencv
, tier4-perception-msgs
, autoware-auto-perception-msgs
, cuda-utils
, tensorrt-common
, cudatoolkit
, builtin-interfaces
, sensor-msgs
, git
, git-lfs
}:
buildRosPackage rec {
  name = "m4-tensorrt-yolox";
  # This currently has the issue of LFS not working,
  # so the models are not pulled.
  src = builtins.fetchGit {
    url = "git@github.com:tier4/m4_tensorrt_yolox.git";
    ref = "main";
    rev = "39d262f02f7a10db1dcec5b0f8fcbc62f38a58b9";
  };

  postFetch = ''
    git lfs pull
  '';

  buildType = "ament_cmake";
  buildInputs = [
    ament-cmake
    ament-cmake-core
    ament-cmake-auto
    ament-lint-auto
    rclcpp-components
    image-transport
    cv-bridge
    opencv
    tier4-perception-msgs
    autoware-auto-perception-msgs
    cuda-utils
    tensorrt-common
    cudatoolkit
  ];
  nativeBuildInputs = buildInputs ++ [ git git-lfs ];
  checkInputs = [ ament-lint-common ];
  propagatedBuildInputs = [
    builtin-interfaces
    sensor-msgs
  ];
}
