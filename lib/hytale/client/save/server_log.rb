# frozen_string_literal: true

module Hytale
  module Client
    class Save
      class ServerLog
        attr_reader :path

        def initialize(path)
          @path = path
        end

        def filename
          File.basename(path)
        end

        def content
          File.read(path)
        end

        def lines
          content.lines
        end

        def created_at
          match = filename.match(/(\d{4})-(\d{2})-(\d{2})_(\d{2})-(\d{2})-(\d{2})/)

          return File.mtime(path) unless match

          Time.new(
            match[1].to_i, match[2].to_i, match[3].to_i,
            match[4].to_i, match[5].to_i, match[6].to_i
          )
        end

        def to_s
          "ServerLog: #{filename}"
        end
      end
    end
  end
end
