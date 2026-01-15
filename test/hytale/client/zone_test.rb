# frozen_string_literal: true

require "test_helper"

class ZoneModuleTest < Minitest::Spec
  before do
    skip_unless_game_installed
  end

  it "should return all zones" do
    zones = Hytale::Client::Zone.all

    assert_instance_of Array, zones
    assert(zones.all? { |z| z.is_a?(Hytale::Client::Zone::Base) })
    assert(zones.any? { |z| z.id == "Emerald_Wilds" })
  end

  it "should find a zone by id" do
    zone = Hytale::Client::Zone.find("Emerald_Wilds")

    assert_instance_of Hytale::Client::Zone::Base, zone
    assert_equal "Emerald_Wilds", zone.id
  end

  it "should return nil for unknown zone" do
    zone = Hytale::Client::Zone.find("Unknown_Zone")

    assert_nil zone
  end

  it "should create a zone with Zone.new" do
    zone = Hytale::Client::Zone.new("Emerald_Wilds")

    assert_instance_of Hytale::Client::Zone::Base, zone
  end
end
