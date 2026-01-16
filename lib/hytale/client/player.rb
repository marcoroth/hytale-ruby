# frozen_string_literal: true

module Hytale
  module Client
    class Player
      attr_reader :data, :uuid, :path

      def initialize(data, uuid:, path: nil)
        @data = data
        @uuid = uuid
        @path = path
      end

      def components
        data["Components"] || {}
      end

      def name
        components.dig("Nameplate", "Text") || components.dig("DisplayName", "DisplayName", "RawText")
      end

      def position
        transform = components["Transform"] || {}
        pos = transform["Position"] || {}

        Position.new(pos["X"], pos["Y"], pos["Z"])
      end

      def rotation
        transform = components["Transform"] || {}
        rot = transform["Rotation"] || {}

        Rotation.new(rot["Pitch"], rot["Yaw"], rot["Roll"])
      end

      def velocity
        vel = components.dig("Velocity", "Velocity") || {}
        Vector3.new(vel["X"], vel["Y"], vel["Z"])
      end

      def stats
        @stats ||= EntityStats.new(components["EntityStats"] || {})
      end

      def inventory
        @inventory ||= Inventory.new(components.dig("Player", "Inventory") || {})
      end

      def player_data
        components["Player"] || {}
      end

      def game_mode
        player_data["GameMode"]
      end

      def current_world
        player_data.dig("PlayerData", "World")
      end

      def discovered_zones
        @discovered_zones ||= (player_data.dig("PlayerData", "DiscoveredZones") || []).map do |id|
          Hytale::Client::Zone::Region.new(id)
        end
      end

      def discovered_instances
        @discovered_instances ||= (player_data.dig("PlayerData", "DiscoveredInstances") || []).map do |instance|
          decode_binary_uuid(instance)
        end.compact
      end

      def respawn_points
        @respawn_points ||= (player_data.dig("PlayerData", "PerWorldData", "default", "RespawnPoints") || []).map do |point|
          RespawnPoint.new(point)
        end
      end

      def death_positions
        @death_positions ||= (player_data.dig("PlayerData", "PerWorldData", "default", "DeathPositions") || []).map do |pos|
          DeathPosition.new(pos)
        end
      end

      def memories
        @memories ||= (components.dig("PlayerMemories", "Memories") || []).map do |mem|
          PlayerMemory.new(mem)
        end
      end

      def known_recipes
        player_data.dig("PlayerData", "KnownRecipes") || []
      end

      def unique_item_usages
        components.dig("UniqueItemUsages", "UniqueItemUsed") || []
      end

      def head_rotation
        rot = components.dig("HeadRotation", "Rotation") || {}

        Rotation.new(rot["Pitch"], rot["Yaw"], rot["Roll"])
      end

      def flying?
        player_data.dig("PlayerData", "PerWorldData", "default", "LastMovementStates", "Flying") || false
      end

      def first_spawn?
        player_data.dig("PlayerData", "PerWorldData", "default", "FirstSpawn") || false
      end

      def active_objectives
        @active_objectives ||= (player_data.dig("PlayerData", "ActiveObjectiveUUIDs") || []).map do |obj|
          decode_binary_uuid(obj)
        end.compact
      end

      def reputation_data
        player_data.dig("PlayerData", "ReputationData") || {}
      end

      def saved_hotbars
        @saved_hotbars ||= (player_data.dig("HotbarManager", "SavedHotbars") || []).compact.map do |hotbar|
          ItemStorage.new(hotbar)
        end
      end

      def current_hotbar_index
        player_data.dig("HotbarManager", "CurrentHotbar")
      end

      def skin
        @skin ||= PlayerSkin.find(uuid)
      end

      def avatar_preview_path
        skin&.avatar_preview_path
      end

      def to_h
        data
      end

      class << self
        def load(path)
          raise NotFoundError, "Player file not found: #{path}" unless File.exist?(path)

          uuid = File.basename(path, ".json")
          json = File.read(path)
          data = JSON.parse(json)
          new(data, uuid: uuid, path: path)
        rescue JSON::ParserError => e
          raise ParseError, "Failed to parse player data: #{e.message}"
        end
      end

      private

      def decode_binary_uuid(data)
        return nil unless data.is_a?(Hash) && data["$binary"]

        bytes = Base64.decode64(data["$binary"])
        return nil unless bytes.length == 16

        hex = bytes.unpack1("H*")
        "#{hex[0, 8]}-#{hex[8, 4]}-#{hex[12, 4]}-#{hex[16, 4]}-#{hex[20, 12]}"
      end
    end
  end
end
