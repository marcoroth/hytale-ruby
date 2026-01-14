# frozen_string_literal: true

module Hytale
  module Client
    class LauncherLog
      class LauncherLogEntry
        attr_reader :timestamp, :level, :message, :raw

        LOG_PATTERN = /^time=(\S+)\s+level=(\S+)\s+msg="([^"]*)"(.*)$/

        def initialize(timestamp:, level:, message:, raw:)
          @timestamp = timestamp
          @level = level
          @message = message
          @raw = raw
        end

        def error? = level == "ERROR"
        def warn? = level == "WARN"
        def info? = level == "INFO"
        def debug? = level == "DEBUG"

        def attributes
          attrs = {}

          raw.scan(/(\w+)=(\S+|"[^"]*")/).each do |key, value|
            next if ["time", "level", "msg"].include?(key)

            attrs[key] = value.delete_prefix('"').delete_suffix('"')
          end

          attrs
        end

        def to_s
          "[#{timestamp}] #{level}: #{message}"
        end

        class << self
          def parse(line)
            return nil unless (match = line.match(LOG_PATTERN))

            timestamp = begin
              Time.parse(match[1])
            rescue StandardError
              nil
            end

            level = match[2]
            message = match[3]

            new(timestamp: timestamp, level: level, message: message, raw: line)
          end
        end
      end
    end
  end
end
