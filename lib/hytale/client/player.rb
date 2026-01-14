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
        player_data.dig("PlayerData", "DiscoveredZones") || []
      end

      def respawn_points
        player_data.dig("PlayerData", "PerWorldData", "default", "RespawnPoints") || []
      end

      def memories
        @memories ||= (components.dig("PlayerMemories", "Memories") || []).map do |mem|
          PlayerMemory.new(mem)
        end
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
    end
  end
end
