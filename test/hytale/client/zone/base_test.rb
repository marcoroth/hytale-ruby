# frozen_string_literal: true

require "test_helper"

class ZoneBaseTest < Minitest::Spec
  before do
    skip_unless_game_installed
  end

  it "should return the id" do
    zone = Hytale::Client::Zone::Base.new("Emerald_Wilds")

    assert_equal "Emerald_Wilds", zone.id
  end

  it "should return the name" do
    zone = Hytale::Client::Zone::Base.new("Emerald_Wilds")

    assert_equal "Emerald Wilds", zone.name
  end

  it "should fallback to id when no translation exists" do
    zone = Hytale::Client::Zone::Base.new("Unknown_Zone")

    assert_equal "Unknown_Zone", zone.name
  end

  it "should be equal to another zone with same id" do
    zone1 = Hytale::Client::Zone::Base.new("Emerald_Wilds")
    zone2 = Hytale::Client::Zone::Base.new("Emerald_Wilds")

    assert_equal zone1, zone2
  end

  it "should be equal to a string with same id" do
    zone = Hytale::Client::Zone::Base.new("Emerald_Wilds")

    assert_equal zone, "Emerald_Wilds"
  end

  it "should return regions for the zone" do
    zone = Hytale::Client::Zone::Base.new("Emerald_Wilds")

    regions = zone.regions

    assert_instance_of Array, regions
    assert(regions.all? { |r| r.is_a?(Hytale::Client::Zone::Region) })
    assert(regions.all? { |r| r.id.start_with?("Zone1") })
  end

  it "should return empty array for unknown zone" do
    zone = Hytale::Client::Zone::Base.new("Unknown_Zone")

    assert_empty zone.regions
  end

  it "should allow navigating from zone to region and back" do
    zone = Hytale::Client::Zone::Base.new("Emerald_Wilds")
    region = zone.regions.first

    assert_equal zone.id, region.zone.id
  end
end
