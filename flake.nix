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
    nvimConfig = {
      url = "github:NewDawn0/nvimConfig";
      inputs.utils.follows = "utils";
    };
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
      inputConfigs = with inputs; [
        # Configured programs
        hxConfig
        nvimConfig
        tmuxConfig
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
      overlays = map (e: e.overlays.default) inputConfigs;
    in {
      overlays.default = final: prev: {
        frosted-flakes-all = self.packages.${prev.system}.default;
        pac = self.packages.${prev.system}.pac;
      };
      packages = utils.lib.eachSystem { inherit overlays; } (pkgs:
        let
          getPkgs = ins:
            with builtins;
            filter (e: e != "default")
            (attrNames (ins.overlays.default { } { }));
          pkgsList = builtins.concatLists (map getPkgs inputConfigs);
          pkgsSet = with builtins;
            listToAttrs (map (pkg: {
              name = pkg;
              value = pkgs.${pkg};
            }) pkgsList);
        in pkgsSet // {
          default = pkgs.symlinkJoin {
            name = "frosted-flakes-all";
            paths = map (p: pkgs.${p}) pkgsList;
          };
        });
    };
}
