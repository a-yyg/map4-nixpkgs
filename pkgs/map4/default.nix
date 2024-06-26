{ callPackage
, cudnn-cmake-module
, tensorrt-cmake-module
, tensorrt
, cudnn
, ... }:
let
  autoware-auto-msgs = callPackage ./autoware-auto-msgs { };
  cuda-utils = callPackage ./cuda-utils { };
  tensorrt-common = callPackage ./tensorrt-common {
    inherit
      cudnn-cmake-module
      tensorrt-cmake-module
      tensorrt
      cudnn;
  };
  tier4-autoware-msgs = callPackage ./tier4-autoware-msgs {
    inherit (autoware-auto-msgs) autoware-auto-perception-msgs;
  };
  m4-tensorrt-yolox = callPackage ./m4-tensorrt-yolox {
    inherit
      cuda-utils
      tensorrt-common;
      # cudnn-cmake-module
      # tensorrt-cmake-module
      # tensorrt
      # cudnn;
    inherit (autoware-auto-msgs)
      autoware-auto-perception-msgs;
    inherit (tier4-autoware-msgs)
      tier4-perception-msgs;
  };
in 
{
  inherit
  autoware-auto-msgs
  cuda-utils
  m4-tensorrt-yolox
  tensorrt-common
  tier4-autoware-msgs;
}
