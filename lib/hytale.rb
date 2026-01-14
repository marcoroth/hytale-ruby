# frozen_string_literal: true

require "json"
require "time"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("npc_memory" => "NPCMemory")
loader.setup

module Hytale
  class Error < StandardError; end
  class NotFoundError < Error; end
  class ParseError < Error; end

  class << self
    def client
      Client
    end

    def settings
      Client.settings
    end

    def saves
      Client.saves
    end

    def players
      Client.players
    end

    def launcher_log
      Client.launcher_log
    end

    def server
      Server
    end
  end
end

loader.eager_load
