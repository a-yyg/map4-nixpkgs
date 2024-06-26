{ callPackage, ... }:
let
  autoware-msgs = callPackage ./autoware-msgs { };
  cudnn-cmake-module = callPackage ./cudnn-cmake-module { };
  tensorrt-cmake-module = callPackage ./tensorrt-cmake-module { };
  packages = {
    autoware-msgs = autoware-msgs;
    cudnn-cmake-module = cudnn-cmake-module;
    tensorrt-cmake-module = tensorrt-cmake-module;
  };
  overlay = self: super: {
    autoware-msgs = autoware-msgs;
    cudnn-cmake-module = cudnn-cmake-module;
    tensorrt-cmake-module = tensorrt-cmake-module;
  };
in packages //
{
  overlay = overlay;
}
