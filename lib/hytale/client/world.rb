# frozen_string_literal: true

module Hytale
  module Client
    class World
      attr_reader :data, :path

      def initialize(data, path: nil)
        @data = data
        @path = path
      end

      def version = data["Version"]
      def uuid = data.dig("UUID", "$binary")
      def display_name = data["DisplayName"]
      def seed = data["Seed"]

      def world_gen
        data["WorldGen"] || {}
      end

      def world_gen_type = world_gen["Type"]
      def world_gen_name = world_gen["Name"]

      def game_mode = data["GameMode"]
      def ticking? = data["IsTicking"]
      def block_ticking? = data["IsBlockTicking"]
      def pvp_enabled? = data["IsPvpEnabled"]
      def fall_damage_enabled? = data["IsFallDamageEnabled"]
      def game_time_paused? = data["IsGameTimePaused"]
      def game_time = data["GameTime"]

      def spawning_npcs? = data["IsSpawningNPC"]
      def npcs_frozen? = data["IsAllNPCFrozen"]

      def daytime_duration = data["DaytimeDurationSeconds"] || 0
      def nighttime_duration = data["NighttimeDurationSeconds"] || 0
      def full_day_duration = (daytime_duration || 0) + (nighttime_duration || 0)

      def death_settings
        @death_settings ||= DeathSettings.new(data["Death"] || {})
      end

      def client_effects
        @client_effects ||= ClientEffects.new(data["ClientEffects"] || {})
      end

      def saving_players? = data["IsSavingPlayers"]
      def saving_chunks? = data["IsSavingChunks"]
      def save_new_chunks? = data["SaveNewChunks"]
      def unloading_chunks? = data["IsUnloadingChunks"]

      def to_h = data

      def name
        return nil unless path

        File.basename(File.dirname(path))
      end

      # Path is: /save_path/universe/worlds/world_name/config.json
      def save_path
        return nil unless path

        File.expand_path("../../..", File.dirname(path))
      end

      def map
        return nil unless path

        Map.new(save_path, world_name: name)
      end

      class << self
        def load(path)
          raise NotFoundError, "World config not found: #{path}" unless File.exist?(path)

          json = File.read(path)
          data = JSON.parse(json)

          new(data, path: path)
        rescue JSON::ParserError => e
          raise ParseError, "Failed to parse world config: #{e.message}"
        end
      end
    end
  end
end
