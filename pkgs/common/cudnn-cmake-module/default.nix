{ lib
, buildRosPackage
, fetchFromGitHub
, fetchurl
, ament-cmake-auto
, ament-lint-auto
, ament-lint-common
, cudatoolkit
}:
let
  findCUDNN = fetchurl {
    url = "https://raw.githubusercontent.com/opencv/opencv/0677f3e21cc3379e68d517dc80a8c12e5df0c608/cmake/FindCUDNN.cmake";
    sha256 = "sha256-pvm3+OkJ6qjN3Av6hrgKjmj3O52wFUsl/8eb9e7VL2Y=";
  };
in
buildRosPackage {
  name = "cudnn-cmake-module";

  src = fetchFromGitHub {
    owner = "tier4";
    repo = "cudnn_cmake_module";
    rev = "main";
    sha256 = "sha256-soUjq5fiwC/MYoBiY1p7TkNuZSg2qLp1N0l+Aem6goI=";
  };

  postUnpack = ''
    cp ${findCUDNN} source/cmake/Modules/FindCUDNN.cmake
  '';

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
