{ lib
, buildRosPackage
, fetchFromGitHub
, ament-cmake-auto
, ament-lint-auto
, ament-lint-common
, cudatoolkit
}:
buildRosPackage {
  name = "m4-cuda-utils";
  # pname = "m4-cuda-utils";
  # version = "0.0.0";

  src = fetchFromGitHub {
    owner = "MapIV";
    repo = "cuda_utils";
    rev = "main";
    sha256 = "sha256-Y+gISFoXK+GSzllRXvwRqGlofPGqg0b4OokUhLqDwyk=";
  };

  buildType = "ament_cmake";
  buildInputs = [ ament-cmake-auto cudatoolkit ];
  checkInputs = [ ament-lint-auto ament-lint-common ];
  propagatedBuildInputs = [];
  nativeBuildInputs = [ ament-cmake-auto ];

  meta = {
    description = "Interfaces between core Autoware.Auto components";
    license = with lib.licenses; [ asl20 ];
  };
}
