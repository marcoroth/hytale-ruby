# frozen_string_literal: true

module Hytale
  module Client
    class LauncherLog
      class LauncherLogSession
        attr_reader :started_at, :entries

        def initialize(started_at)
          @started_at = started_at
          @entries = []
        end

        def add_entry(entry)
          @entries << entry
        end

        def version
          start_entry = entries.find { |e| e.message&.include?("starting hytale-launcher") }

          start_entry&.attributes&.[]("version")
        end

        def profile_uuid
          profile_entry = entries.find { |e| e.message&.include?("setting current profile") }

          profile_entry&.message&.match(/to (\S+)/)&.[](1)
        end

        def game_launched?
          entries.any? { |e| e.message&.include?("starting game process") }
        end

        def errors
          entries.select(&:error?)
        end

        def duration
          return nil if entries.empty?

          last_time = entries.last.timestamp
          first_time = entries.first.timestamp

          return nil unless last_time && first_time

          last_time - first_time
        end

        def to_s
          "Session at #{started_at} (v#{version})"
        end
      end
    end
  end
end
