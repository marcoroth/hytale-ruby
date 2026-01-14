# frozen_string_literal: true

module Hytale
  module Client
    class << self
      def data_path
        Config.data_path
      end

      def data_path=(path)
        Config.data_path = path
      end

      def settings
        Settings.load
      end

      def saves
        Save.all
      end

      def save(name)
        Save.find(name)
      end

      def launcher_log
        LauncherLog.load
      end

      def prefabs
        prefabs_path = Config.prefabs_path
        return [] unless prefabs_path && File.directory?(prefabs_path)

        Dir.glob(File.join(prefabs_path, "**", "*.lpf")).map do |path|
          Prefab.load(path)
        end
      end

      def prefab(name)
        prefabs.find { |p| p.name == name || p.filename == name }
      end

      def prefab_categories
        prefabs_path = Config.prefabs_path

        return [] unless prefabs_path && File.directory?(prefabs_path)

        Dir.children(prefabs_path).select do |entry|
          File.directory?(File.join(prefabs_path, entry))
        end.sort
      end

      def prefabs_in_category(category)
        prefabs_path = Config.prefabs_path
        return [] unless prefabs_path

        category_path = File.join(prefabs_path, category)
        return [] unless File.directory?(category_path)

        Dir.glob(File.join(category_path, "**", "*.lpf")).map do |path|
          Prefab.load(path)
        end
      end

      def block_types
        BlockType.all
      end

      def block_type(id)
        BlockType.find(id) || BlockType.new(id)
      end

      def block_type_categories
        BlockType.categories
      end

      def block_types_in_category(category)
        BlockType.where(category: category)
      end

      alias blocks block_types
      alias block block_type
      alias block_categories block_type_categories
      alias blocks_in_category block_types_in_category

      def item_types
        ItemType.all
      end

      def item_type(id)
        ItemType.find(id) || ItemType.new(id)
      end

      def item_type_categories
        ItemType.categories
      end

      def item_types_in_category(category)
        ItemType.where(category: category)
      end

      alias items item_types
      alias item item_type

      def locales
        Locale.all
      end

      def locale(code = Locale.default)
        Locale.find(code) || Locale.new(code)
      end

      def players
        saves.flat_map(&:players)
      end

      def player(uuid)
        players.find { |p| p.uuid == uuid }
      end

      def player_skins
        PlayerSkin.all
      end

      def player_skin(uuid)
        PlayerSkin.find(uuid)
      end

      def installed?
        Config.exists?
      end

      def running?
        Process.running?
      end

      def processes
        Process.list
      end
    end
  end
end
