# frozen_string_literal: true

module Hytale
  module Client
    class Save
      class Backup
        attr_reader :path

        def initialize(path)
          @path = path
        end

        def filename
          File.basename(path)
        end

        def size
          File.size(path)
        end

        def size_mb
          (size / 1024.0 / 1024.0).round(2)
        end

        # Parse from filename: 2026-01-13_17-36-28.zip
        def created_at
          match = filename.match(/(\d{4})-(\d{2})-(\d{2})_(\d{2})-(\d{2})-(\d{2})/)

          return File.mtime(path) unless match

          Time.new(
            match[1].to_i, match[2].to_i, match[3].to_i,
            match[4].to_i, match[5].to_i, match[6].to_i
          )
        end

        def to_s
          "Backup: #{filename} (#{size_mb} MB)"
        end
      end
    end
  end
end
