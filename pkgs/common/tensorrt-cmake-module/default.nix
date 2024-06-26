{ lib
, buildRosPackage
, fetchFromGitHub
, ament-cmake
, ament-cmake-copyright
, ament-cmake-lint-cmake
, ament-cmake-xmllint
}:
buildRosPackage {
  name = "tensorrt-cmake-module";

  src = fetchFromGitHub {
    owner = "tier4";
    repo = "tensorrt_cmake_module";
    rev = "main";
    sha256 = "sha256-S620gK89qsxhq1mo2yFSZCD1LP45mJBLXJbCTiT5VZk=";
  };

  buildType = "ament_cmake";
  buildInputs = [ ament-cmake ];
  checkInputs = [ ament-cmake-copyright ament-cmake-lint-cmake ament-cmake-xmllint ];
  propagatedBuildInputs = [];
  nativeBuildInputs = [ ament-cmake ];

  meta = {
    description = "Interfaces between core Autoware.Auto components";
    license = with lib.licenses; [ asl20 ];
  };
}
