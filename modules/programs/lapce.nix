{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.lapce;
  
  tomlFormat = pkgs.formats.toml { };
  
  pluginDir = "${config.xdg.dataHome}/lapce-stable/plugins";
  configDir = "${config.xdg.configHome}/lapce-stable";
  
  configFilePath = "${configDir}/settings.toml";
  keymapFilePath = "${configDir}/keymaps.toml";
  
in {
  meta.maintainers = [ maintainers.KaiserCalm ];

  options = {
    programs.lapce = {
      enable = mkEnableOption "Lapce";
      
      package = mkOption {
        type = types.package;
        default = pkgs.lapce;
        defaultText = literalExpression "pkgs.lapce";
        description = "The Lapce package to install.";
      };
      
      settings = mkOption {
        type = tomlFormat.type;
        default = { };
        example = literalExpression ''
          {
            core = {
              color-theme = "Catppuccin Mocha";
              icon-theme = "Material Icons";
              custom-titlebar = true;
            };
          }
        '';
        description = ''
          Configuration written to Lapce's
          {file}`settings.toml`.
        '';
      };
      
      # pkgs.formats.toml.generate seems to not like types.listOf
      keybindings = mkOption {
        type = tomlFormat.type;
        default = { };
        example = literalExpression ''
          {
            keymaps = [
              {
                command = "clipboard_copy";
                mode = "i";
                key = "Ctrl+C";
              }
              {
                command = "-clipboard_paste";
                mode = "i";
                key = "Ctrl+V";
              }
            ];
          }
        '';
        description = ''
          Keybindings written to Lapce's
          {file}`keymaps.toml`.
        '';
      };
      
      # TODO: Add declarative plugin installation support.
      # Lapce gets it's plugins using the url:
      # https://plugins.lapce.dev/api/v1/plugins/dzhou121/lapce-rust/0.3.1896/download
      # Which needs the plugin author, plugin name and plugin version.
      # It then returns a url with the actual plugin file, which is a
      # plugin.volt (but really just a plugin.tar.zstd). 
      # It then puts the extracted plugin in ~/.local/share/lapce-stable/plugins
      # You are welcome to try and implement fetching the plugins from there, 
      # as I could not figure it out.
      #plugins = mkOption {
      #  type = types.listOf pluginModule;
      #  default = [];
      #  example = literalExpression ''
      #    [
      #      {
      #        name = "lapce-rust";
      #        author = "dzhou121";
      #        version = "0.3.1896";
      #      }
      #    ]
      #  '';
      #  description = "Plugins to download from {url}`https://plugins.lapce.dev/`";
      #};
    };
  };
  
  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    
    home.file = mkMerge [
      (mkIf (cfg.settings != { }) {
        "${configFilePath}".source =
          tomlFormat.generate "lapce-settings" cfg.settings;
      })
      (mkIf (cfg.keybindings != { }) {
        "${keymapFilePath}".source =
          tomlFormat.generate "lapce-keymaps" cfg.keybindings;
      })
    ];
  };
}
