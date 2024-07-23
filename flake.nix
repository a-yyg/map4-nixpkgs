{                                                                             
  description = "ROS2 workspace for M4 TensorRT YOLOX";
  nixConfig = {
    extra-trusted-substituters = [ "https://cuda-maintainers.cachix.org" ];     
    extra-public-keys = [ "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E=" ];
  };

  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-23.11";
    jetpack.url = "github:anduril/jetpack-nixos/8f27a0b1406c628b47cfd36932d70a96baf90d72";
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay";
    nix-ros-workspace = {
      flake = false;
      url = "https://github.com/hacker1024/nix-ros-workspace/archive/master.tar.gz";
    };
    nixpkgs.follows = "nix-ros-overlay/nixpkgs"; # Why?
  };

  outputs = { self, nixpkgs, jetpack, nix-ros-overlay, nix-ros-workspace }: 
  let
    cv-bridge-overlay = self: super: {
      rosPackages.humble = super.rosPackages.humble.overrideScope (gfinal: gprev: {
        cv-bridge = gprev.cv-bridge.overrideAttrs (oldAttrs: {
          buildInputs = with gprev; [ ament-cmake-ros ];
          checkInputs = with gprev; [ ament-cmake-gtest ament-lint-auto ament-lint-common ];
          propagatedBuildInputs = with gprev; [ self.boost self.cudaPackages.cudatoolkit self.opencv self.opencv.cxxdev sensor-msgs ];
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
    commonPc = pcPkgs.rosPackages.humble.callPackage ./pkgs/common {};
    map4Pc = pcPkgs.rosPackages.humble.callPackage ./pkgs/map4 {
      inherit (commonPc)
        cudnn-cmake-module
        tensorrt-cmake-module;
      inherit (pcPkgs.cudaPackages) tensorrt cudnn;
    };
    cuda-jetson-overlay = self: super: {
      cudaPackages = super.nvidia-jetpack.cudaPackages // {
        cuda_cudart.lib = super.nvidia-jetpack.cudaPackages.cuda_cudart;
        cuda_cudart.dev = super.nvidia-jetpack.cudaPackages.cuda_cudart;
        cuda_cccl.dev = super.nvidia-jetpack.cudaPackages.cuda_cccl;
        libnpp.dev = super.nvidia-jetpack.cudaPackages.libnpp;
        libnpp.lib = super.nvidia-jetpack.cudaPackages.libnpp;
        libnpp.static = super.nvidia-jetpack.cudaPackages.libnpp;
        libcublas.static = super.nvidia-jetpack.cudaPackages.libcublas;
        libcublas.lib = super.nvidia-jetpack.cudaPackages.libcublas;
        libcublas.dev = super.nvidia-jetpack.cudaPackages.libcublas;
        libcufft.dev = super.nvidia-jetpack.cudaPackages.libcufft;
        libcufft.lib = super.nvidia-jetpack.cudaPackages.libcufft;
        libcufft.static = super.nvidia-jetpack.cudaPackages.libcufft;
        inherit (super.cudaPackages_11_3) backendStdenv;
        inherit (super.cudaPackages_11_4)
          autoAddOpenGLRunpathHook markForCudatoolkitRootHook;
        cudaFlags = super.cudaPackages_11_4.cudaFlags.override {
          config.cudaCapabilities = [ "8.6" ];
          config.cudaForwardCompat = false;
        };
      };
    };
    jetsonPkgs = import nixpkgs {
      system = "aarch64-linux";
      overlays = [
        jetpack.overlays.default
        cuda-jetson-overlay
        nix-ros-overlay.overlays.default
        (import nix-ros-workspace {}).overlay
        cv-bridge-overlay
      ];
      config = {
        allowUnfree = true;
        # allowBroken = true;
        cudaSupport = true;
        cudnnSupport = true;
      };
    };
    commonJetson = jetsonPkgs.rosPackages.humble.callPackage ./pkgs/common {};
    map4Jetson = jetsonPkgs.rosPackages.humble.callPackage ./pkgs/map4 {
      inherit (commonJetson)
        cudnn-cmake-module
        tensorrt-cmake-module;
      inherit (jetsonPkgs.nvidia-jetpack.cudaPackages) tensorrt cudnn;
    };
    # ros2-ipcamera = pcPkgs.rosPackages.humble.callPackage
    #   ./pkgs/ros2-ipcamera {}; # ({} // pcPkgs.rosPackages.humble);
    video-receiver = pcPkgs.rosPackages.humble.callPackage ./pkgs/analogdevicesinc/video-receiver {};
  in
  rec {
    # packages.x86_64-linux.ros2-ipcamera = ros2-ipcamera;
    packages.x86_64-linux.video-receiver = video-receiver;
    packages.x86_64-linux.m4-tensorrt-yolox-pc = map4Pc.m4-tensorrt-yolox;
    packages.x86_64-linux.ros2-pc = pcPkgs.rosPackages.humble.buildROSWorkspace {
      name = "m4-tensorrt-yolox";
      devPackages = {
        inherit (packages.x86_64-linux) m4-tensorrt-yolox-pc ros2-ipcamera;
      };
      prebuiltPackages = {
        inherit (pcPkgs.rosPackages.humble)
          rviz2 ros2bag image-transport compressed-image-transport;
        inherit (map4Pc.tier4-autoware-msgs)
          tier4-perception-msgs;
        # inherit (map4Pc.autoware-auto-msgs)
        #   autoware-auto-perception-msgs;
      };
    };
    packages.aarch64-linux.m4-tensorrt-yolox-jetson = map4Jetson.m4-tensorrt-yolox;
    packages.aarch64-linux.ros2-jetson = jetsonPkgs.rosPackages.humble.buildROSWorkspace {
      name = "m4-tensorrt-yolox";
      devPackages = {
        inherit (packages.aarch64-linux) m4-tensorrt-yolox-jetson;
      };
      prebuiltPackages = {
        inherit (jetsonPkgs.rosPackages.humble)
          rviz2 ros2bag;
      };
    };

    devShells.x86_64-linux.default = pcPkgs.mkShell {
      buildInputs = with pcPkgs; [
        superflore
      ];
    };
  };
}
