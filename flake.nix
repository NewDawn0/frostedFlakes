{
  description = "Frosted flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    utils = {
      url = "github:NewDawn0/nixUtils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Configured programs
    ndnvim.url = "github:NewDawn0/nvimConfig";
    ndvscode.url = "github:NewDawn0/vscodeConfig";
    ndhelix.url = "github:NewDawn0/hxConfig";
    ndtmux = {
      url = "github:NewDawn0/tmuxConfig";
      inputs.utils.follows = "utils";
    };
    # Bins
    ascii-weather = {
      url = "github:NewDawn0/asciiWeather";
      inputs.utils.follows = "utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    build-all = {
      url = "github:NewDawn0/buildAll";
      inputs.utils.follows = "utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cheat = {
      url = "github:NewDawn0/cheat.s";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };
    ex = {
      url = "github:NewDawn0/ex";
      inputs.utils.follows = "utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gen = {
      url = "github:NewDawn0/gen";
      inputs.utils.follows = "utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixie-clock = {
      url = "github:NewDawn0/nixieClock";
      inputs.utils.follows = "utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    note = {
      url = "github:NewDawn0/note";
      inputs.utils.follows = "utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    notify = {
      url = "github:NewDawn0/notify";
      inputs.utils.follows = "utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pac.url = "github:NewDawn0/pac";
    shredder = {
      url = "github:NewDawn0/shredder";
      inputs.utils.follows = "utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    translate = {
      url = "github:NewDawn0/translate";
      inputs.utils.follows = "utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vocab = {
      url = "github:NewDawn0/vocab";
      inputs.utils.follows = "utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, utils, ... }@inputs:
    let
      ins = {
        cfgs = [ "ndhelix" "ndnvim" "ndtmux" "ndvscode" ];
        bins = [
          "ascii-weather"
          "build-all"
          "cheat"
          "ex"
          "gen"
          "nixie-clock"
          "note"
          "notify"
          "pac"
          "shredder"
          "translate"
          "vocab"
        ];
      };
      overlays = map (e: inputs.${e}.overlays.default) (ins.bins ++ ins.cfgs);
      allPkgs = with builtins;
        concatLists (map attrNames (map (e: e { } { }) overlays));
      outPkgs = pkgs:
        with builtins;
        listToAttrs (map (e: {
          name = e;
          value = pkgs.${e};
        }) allPkgs);
      outOverlays = prev:
        with builtins;
        listToAttrs (map (e: {
          name = e;
          value = self.packages.${prev.system}.${e};
        }) allPkgs);
    in {
      overlays.default = final: prev:
        ((outOverlays prev) // {
          frosted-flakes = self.packages.${prev.system}.default;
        });
      packages = utils.lib.eachSystem { inherit overlays; } (pkgs:
        let
          defaults = {
            cfgs.enable = true;
            bins.enable = true;
          };
          frosted-flakes = { cfgs, bins }:
            pkgs.symlinkJoin {
              name = "frosted-flakes";
              paths = [ ] ++ (pkgs.lib.lists.optionals bins.enable
                (map (e: pkgs.${e}) ins.bins))
                ++ (pkgs.lib.lists.optionals cfgs.enable
                  (map (e: pkgs.${e}) ins.cfgs));
            };
        in (outPkgs pkgs) // {
          default = pkgs.lib.makeOverridable frosted-flakes defaults;
        });
    };
}
