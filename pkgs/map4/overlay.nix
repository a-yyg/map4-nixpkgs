# TODO

rosDistro:

final: prev:
{
  map4 = prev.lib.makeScope prev.newScope (self: (let
    map4-pkgs = self.rosPackages."${rosDistro}".callPackage ./default.nix {
      rosDistro = rosDistro;
    };
  in {
    
  }));
}
