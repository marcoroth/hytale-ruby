# frozen_string_literal: true

module Hytale
  module Client
    class Memories
      attr_reader :data, :path

      def initialize(data, path: nil)
        @data = data
        @path = path
      end

      def all
        @all ||= (data["Memories"] || []).map { |mem| NPCMemory.new(mem) }
      end

      def count
        all.size
      end

      def find_by_role(role)
        all.find { |mem| mem.npc_role == role }
      end

      def find_all_by_location(location)
        all.select { |mem| mem.location&.include?(location) }
      end

      def roles
        all.map(&:npc_role).uniq.sort
      end

      def locations
        all.map(&:location).compact.uniq.sort
      end

      def each(&)
        all.each(&)
      end

      include Enumerable

      def to_a = all
      def to_h = data

      class << self
        def load(path)
          raise NotFoundError, "Memories file not found: #{path}" unless File.exist?(path)

          json = File.read(path)
          data = JSON.parse(json)
          new(data, path: path)
        rescue JSON::ParserError => e
          raise ParseError, "Failed to parse memories: #{e.message}"
        end
      end
    end
  end
end
