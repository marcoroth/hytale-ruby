# frozen_string_literal: true

require "bundler/setup"
require "maxitest/autorun"
require "hytale"

module TestHelpers
  def skip_unless_game_installed
    skip "Hytale game not installed" unless game_installed?
  end

  def skip_unless_saves_available
    skip "No saves available" if Hytale::Client.saves.empty?
  end

  def game_installed?
    Hytale::Client::Config.assets_path && File.exist?(Hytale::Client::Config.assets_path)
  end

  def assets_available?
    game_installed? && Hytale::Client::Assets.block_textures.any?
  end

  def fixture_saves_path
    File.expand_path("fixtures/saves", __dir__)
  end

  def fixture_save_path(name = "fixture")
    File.join(fixture_saves_path, name)
  end

  def fixture_map
    @fixture_map ||= Hytale::Client::Map.new(fixture_save_path)
  end

  def fixture_region
    @fixture_region ||= fixture_map.regions.first
  end

  def fixture_player_path
    Dir.glob(File.join(fixture_save_path, "universe/players/*.json")).first
  end
end

module Minitest
  class Test
    include TestHelpers
  end
end
