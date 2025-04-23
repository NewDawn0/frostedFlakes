{
  description = "Your awesome flake";

  inputs = {
    utils.url = "github:NewDawn0/nixUtils";
    # Configured programs
    ndnvim.url = "github:NewDawn0/nvimConfig";
    ndvscode.url = "github:NewDawn0/vscodeConfig";
    ndhelix.url = "github:NewDawn0/hxConfig";
    ndtmux = {
      url = "github:NewDawn0/tmuxConfig";
      inputs.utils.follows = "utils";
    };
    # Bins
    alpha = {
      url = "github:NewDawn0/alpha";
      inputs.utils.follows = "utils";
    };
    ascii-weather = {
      url = "github:NewDawn0/asciiWeather";
      inputs.utils.follows = "utils";
    };
    dir-stack = {
      url = "github:NewDawn0/dirStack";
      inputs.utils.follows = "utils";
    };
    ex = {
      url = "github:NewDawn0/ex";
      inputs.utils.follows = "utils";
    };
    gen = {
      url = "github:NewDawn0/gen";
      inputs.utils.follows = "utils";
    };
    nixie-clock = {
      url = "github:NewDawn0/nixieClock";
      inputs.utils.follows = "utils";
    };
    note = {
      url = "github:NewDawn0/note";
      inputs.utils.follows = "utils";
    };
    notify = {
      url = "github:NewDawn0/notify";
      inputs.utils.follows = "utils";
    };
    pac.url = "github:NewDawn0/pac";
    shredder = {
      url = "github:NewDawn0/shredder";
      inputs.utils.follows = "utils";
    };
    translate = {
      url = "github:NewDawn0/translate";
      inputs.utils.follows = "utils";
    };
    vocab = {
      url = "github:NewDawn0/vocab";
      inputs.utils.follows = "utils";
    };
  };

  outputs = { self, utils, ... }@inputs:
    let
      ins = {
        cfgs = [ "ndhelix" "ndnvim" "ndtmux" "ndvscode" ];
        bins = [
          "alpha"
          "ascii-weather"
          "dir-stack"
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
      outOverlays = with builtins;
        listToAttrs (map (e: {
          name = e;
          value = self.packages.${e};
        }) allPkgs);
    in {
      overlays.default = final: prev:
        (outOverlays // {
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
