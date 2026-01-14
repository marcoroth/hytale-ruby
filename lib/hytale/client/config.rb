# frozen_string_literal: true

module Hytale
  module Client
    module Config
      class << self
        def data_path
          @data_path ||= default_data_path
        end

        attr_writer :data_path

        def reset!
          @data_path = nil
        end

        def default_data_path
          case RUBY_PLATFORM
          when /darwin/
            File.expand_path("~/Library/Application Support/Hytale")
          when /mswin|mingw|cygwin/
            File.join(ENV.fetch("APPDATA", ""), "Hytale")
          when /linux/
            File.expand_path("~/.local/share/Hytale")
          else
            raise Error, "Unsupported platform: #{RUBY_PLATFORM}"
          end
        end

        def user_data_path
          File.join(data_path, "UserData")
        end

        def settings_path
          File.join(user_data_path, "Settings.json")
        end

        def saves_path
          File.join(user_data_path, "Saves")
        end

        def logs_path
          File.join(user_data_path, "Logs")
        end

        def telemetry_path
          File.join(user_data_path, "Telemetry")
        end

        def launcher_log_path
          File.join(data_path, "hytale-launcher.log")
        end

        def install_path
          File.join(data_path, "install")
        end

        def prefab_cache_path
          File.join(user_data_path, "PrefabCache")
        end

        def player_skins_path
          File.join(user_data_path, "CachedPlayerSkins")
        end

        def avatar_previews_path
          File.join(user_data_path, "CachedAvatarPreviews")
        end

        def prefabs_path
          pattern = File.join(prefab_cache_path, "*", "Server", "Prefabs")
          dirs = Dir.glob(pattern)

          dirs.first
        end

        def assets_path
          pattern = File.join(install_path, "release", "package", "game", "*", "Assets.zip")
          files = Dir.glob(pattern)

          files.first
        end

        def assets_cache_path
          @assets_cache_path ||= File.expand_path("assets", gem_root)
        end

        attr_writer :assets_cache_path

        def gem_root
          File.expand_path("../../..", __dir__)
        end

        def exists?
          File.directory?(data_path)
        end
      end
    end
  end
end
