{                                                                             
  description = "ROS2 workspace for M4 TensorRT YOLOX";
  nixConfig = {
    extra-trusted-substituters = [ "https://cuda-maintainers.cachix.org" ];     
    extra-public-keys = [ "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E=" ];
  };

  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-23.11";
    # jetpack.url = "github:anduril/jetpack-nixos/8f27a0b1406c628b47cfd36932d70a96baf90d72";
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay";
    nix-ros-workspace = {
      flake = false;
      url = "https://github.com/hacker1024/nix-ros-workspace/archive/master.tar.gz";
    };
    nixpkgs.follows = "nix-ros-overlay/nixpkgs"; # Why?
  };

  outputs = { self, nixpkgs, nix-ros-overlay, nix-ros-workspace }: 
  let
    cv-bridge-overlay = self: super: {
      rosPackages.humble = super.rosPackages.humble.overrideScope (gfinal: gprev: {
        cv-bridge = gprev.cv-bridge.overrideAttrs (oldAttrs: {
          buildInputs = with gprev; [ ament-cmake-ros ];
          checkInputs = with gprev; [ ament-cmake-gtest ament-lint-auto ament-lint-common ];
          propagatedBuildInputs = with gprev; [ self.boost self.opencv self.opencv.cxxdev sensor-msgs ];
          nativeBuildInputs = with gprev; [ ament-cmake-ros ];
          dontUseCmakeConfigure = false;
          prePatch = ''
            sed -i 's/ANDROID/TRUE/' CMakeLists.txt
            sed -i 's/ANDROID/TRUE/' src/CMakeLists.txt
          '';
        });
      });
    };
    pcPkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [
        nix-ros-overlay.overlays.default
        (import nix-ros-workspace {}).overlay
        cv-bridge-overlay
      ];
      config = {
        allowUnfree = true;
        allowBroken = true;
        cudaSupport = true;
        cudnnSupport = true;
      };
    };
    common = pcPkgs.rosPackages.humble.callPackage ./pkgs/common {};
    map4 = pcPkgs.rosPackages.humble.callPackage ./pkgs/map4 {
      inherit (common)
        cudnn-cmake-module
        tensorrt-cmake-module;
      inherit (pcPkgs.cudaPackages) tensorrt cudnn;
    };
  in
  rec {
    packages.x86_64-linux.m4-tensorrt-yolox-pc = map4.m4-tensorrt-yolox;
    packages.x86_64-linux.ros2-pc = pcPkgs.rosPackages.humble.buildROSWorkspace {
      name = "m4-tensorrt-yolox";
      devPackages = {
        inherit (packages.x86_64-linux) m4-tensorrt-yolox-pc;
      };
      prebuiltPackages = {
        inherit (pcPkgs.rosPackages.humble)
          rviz2 ros2bag;
      };
    };
  };
}
