# frozen_string_literal: true

module Hytale
  module Client
    class LauncherLog
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def content
        @content ||= File.read(path)
      end

      def lines
        @lines ||= content.lines.map(&:chomp)
      end

      def entries
        @entries ||= lines.filter_map { |line| LauncherLogEntry.parse(line) }
      end

      def errors
        entries.select(&:error?)
      end

      def warnings
        entries.select(&:warn?)
      end

      def info
        entries.select(&:info?)
      end

      def game_launches
        entries.select { |e| e.message&.include?("starting game process") }
      end

      def updates
        entries.select { |e| e.message&.include?("applying update") }
      end

      def current_version
        version_entry = entries.reverse.find { |e| e.message&.include?("starting hytale-launcher") }
        version_entry&.attributes&.[]("version")
      end

      def current_profile_uuid
        profile_entry = entries.reverse.find { |e| e.message&.include?("setting current profile") }
        profile_entry&.message&.match(/to (\S+)/)&.[](1)
      end

      def current_channel
        channel_entry = entries.reverse.find { |e| e.message&.include?("setting channel") }
        channel_entry&.attributes&.[]("channel")
      end

      def last_game_launch
        game_launches.last
      end

      def sessions
        # Group entries by launcher start
        sessions = []
        current_session = nil

        entries.each do |entry|
          if entry.message&.include?("starting hytale-launcher")
            current_session = LauncherLogSession.new(entry.timestamp)
            sessions << current_session
          end
          current_session&.add_entry(entry)
        end

        sessions
      end

      def each(&)
        entries.each(&)
      end

      include Enumerable

      class << self
        def load(path: Config.launcher_log_path)
          raise NotFoundError, "Launcher log not found: #{path}" unless File.exist?(path)

          new(path)
        end
      end
    end
  end
end
