{
  description = "Your awesome flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils = {
      url = "github:NewDawn0/nixUtils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Configured programs
    hxConfig = {
      url = "github:NewDawn0/hxConfig";
      inputs.utils.follows = "utils";
    };
    nvimConfig.url = "github:NewDawn0/nvimConfig";
    tmuxConfig = {
      url = "github:NewDawn0/tmuxConfig";
      inputs.utils.follows = "utils";
    };
    # Bins
    alpha = {
      url = "github:NewDawn0/alpha";
      inputs.utils.follows = "utils";
    };
    ansi.url = "github:NewDawn0/ansi";
    asciiWeather = {
      url = "github:NewDawn0/asciiWeather";
      inputs.utils.follows = "utils";
    };
    dirStack = {
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
    nixieClock = {
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
    pac = {
      url = "github:NewDawn0/pac";
      inputs.utils.follows = "utils";
    };
    shredder = {
      url = "github:NewDawn0/shredder";
      inputs.utils.follows = "utils";
    };
    translate = {
      url = "github:NewDawn0/translate";
      inputs.utils.follows = "utils";
    };
    up = {
      url = "github:NewDawn0/up";
      inputs.utils.follows = "utils";
    };
    vocab = {
      url = "github:NewDawn0/vocab";
      inputs.utils.follows = "utils";
    };
  };

  outputs = { self, utils, ... }@inputs:
    let
      cfgInputs = with inputs; [ hxConfig nvimConfig tmuxConfig ];
      binInputs = with inputs; [
        # Configured programs
        # Bins
        alpha
        ansi
        asciiWeather
        dirStack
        ex
        gen
        nixieClock
        note
        notify
        pac
        shredder
        translate
        up
        vocab
      ];
      overlays = map (e: e.overlays.default) (cfgInputs ++ binInputs);
      getPkgs = ins:
        with builtins;
        filter (e: e != "default") (attrNames (ins.overlays.default { } { }));
      pkgsList = builtins.concatLists (map getPkgs (binInputs ++ cfgInputs));
      pkgsListNoConfig = builtins.concatLists (map getPkgs binInputs);
      pkgsSet = fmt: with builtins; listToAttrs (map fmt pkgsList);
    in {
      overlays.default = final: prev:
        ((pkgsSet (pkg: {
          name = pkg;
          value = self.packages.${prev.system}.${pkg};
        })) // {
          frosted-flakes = self.packages.${prev.system}.default;
          frosted-flakes-no-configs =
            self.packages.${prev.system}.frosted-flakes-no-configs;
        });
      packages = utils.lib.eachSystem { inherit overlays; } (pkgs:
        let
          frosted-flakes = pkgs.symlinkJoin {
            name = "frosted-flakes";
            paths = map (p: pkgs.${p}) pkgsList;
          };
          frosted-flakes-no-configs = pkgs.symlinkJoin {
            name = "frosted-flakes-no-configs";
            paths = map (p: pkgs.${p}) pkgsListNoConfig;
          };
        in (pkgsSet (pkg: {
          name = pkg;
          value = pkgs.${pkg};
        })) // {
          inherit frosted-flakes frosted-flakes-no-configs;
          default = frosted-flakes-no-configs;
        });
    };
}
