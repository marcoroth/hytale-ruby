# frozen_string_literal: true

module Hytale
  module Client
    class Save
      attr_reader :name, :path

      def initialize(name, path: nil)
        @name = name
        @path = path || File.join(Config.saves_path, name)
      end

      def exists?
        File.directory?(path)
      end

      def world(name = "default")
        world_path = File.join(path, "universe", "worlds", name, "config.json")
        World.load(world_path)
      end

      def map(world_name = "default")
        Map.new(path, world_name: world_name)
      end

      def worlds
        worlds_path = File.join(path, "universe", "worlds")

        return [] unless File.directory?(worlds_path)

        Dir.children(worlds_path)
           .select { |d| File.directory?(File.join(worlds_path, d)) }
           .map { |name| world(name) }
      end

      def world_names
        worlds_path = File.join(path, "universe", "worlds")

        return [] unless File.directory?(worlds_path)

        Dir.children(worlds_path)
           .select { |d| File.directory?(File.join(worlds_path, d)) }
           .sort
      end

      def maps
        world_names.map { |name| map(name) }
      end

      def players
        players_path = File.join(path, "universe", "players")

        return [] unless File.directory?(players_path)

        Dir.glob(File.join(players_path, "*.json"))
           .reject { |f| f.end_with?(".bak") }
           .map { |f| Player.load(f) }
      end

      def player(uuid)
        player_path = File.join(path, "universe", "players", "#{uuid}.json")
        Player.load(player_path)
      end

      def memories
        memories_path = File.join(path, "universe", "memories.json")

        return Memories.new({}) unless File.exist?(memories_path)

        Memories.load(memories_path)
      end

      def permissions
        permissions_path = File.join(path, "permissions.json")

        return Permissions.new({}) unless File.exist?(permissions_path)

        Permissions.load(permissions_path)
      end

      def bans
        bans_path = File.join(path, "bans.json")
        return [] unless File.exist?(bans_path)

        JSON.parse(File.read(bans_path))
      end

      def whitelist
        whitelist_path = File.join(path, "whitelist.json")
        return [] unless File.exist?(whitelist_path)

        JSON.parse(File.read(whitelist_path))
      end

      def preview_path
        File.join(path, "preview.png")
      end

      def preview_exists?
        File.exist?(preview_path)
      end

      def backups
        backup_path = File.join(path, "backup")
        return [] unless File.directory?(backup_path)

        Dir.glob(File.join(backup_path, "*.zip")).map do |f|
          Backup.new(f)
        end.sort_by(&:created_at).reverse
      end

      def logs
        logs_path = File.join(path, "logs")
        return [] unless File.directory?(logs_path)

        Dir.glob(File.join(logs_path, "*.log")).map do |f|
          ServerLog.new(f)
        end.sort_by(&:created_at).reverse
      end

      def mods_path
        File.join(path, "mods")
      end

      def mods
        return [] unless File.directory?(mods_path)

        Dir.children(mods_path).select { |d| File.directory?(File.join(mods_path, d)) }
      end

      def to_s
        "Save: #{name}"
      end

      class << self
        def all
          return [] unless File.directory?(Config.saves_path)

          Dir.children(Config.saves_path)
             .select { |d| File.directory?(File.join(Config.saves_path, d)) }
             .map { |name| new(name) }
        end

        def find(name)
          save = new(name)
          raise NotFoundError, "Save not found: #{name}" unless save.exists?

          save
        end

        def exists?(name)
          File.directory?(File.join(Config.saves_path, name))
        end
      end
    end
  end
end
