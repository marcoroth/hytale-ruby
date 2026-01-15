# frozen_string_literal: true

require "test_helper"

class ZoneRegionTest < Minitest::Spec
  before do
    @region = Hytale::Client::Zone::Region.new("Zone1_Spawn")
  end

  it "should return the id" do
    assert_equal "Zone1_Spawn", @region.id
  end

  it "should return the name" do
    assert_equal @region.name, @region.to_s
  end

  it "should fallback to id when no translation exists" do
    region = Hytale::Client::Zone::Region.new("Unknown_Zone")

    assert_equal "Unknown_Zone", region.name
  end

  it "should be equal to another region with same id" do
    other = Hytale::Client::Zone::Region.new("Zone1_Spawn")

    assert_equal @region, other
  end

  it "should be equal to a string with same id" do
    assert_equal @region, "Zone1_Spawn"
  end

  it "should not be equal to different region" do
    other = Hytale::Client::Zone::Region.new("Zone1_Tier1")

    refute_equal @region, other
  end

  it "should have consistent hash for same id" do
    other = Hytale::Client::Zone::Region.new("Zone1_Spawn")

    assert_equal @region.hash, other.hash
  end

  it "should work in arrays with include?" do
    regions = [@region]

    assert_includes regions, "Zone1_Spawn"
    assert_includes regions, Hytale::Client::Zone::Region.new("Zone1_Spawn")
  end

  it "should return the parent zone" do
    region = Hytale::Client::Zone::Region.new("Zone1_Tier1")

    zone = region.zone

    assert_instance_of Hytale::Client::Zone::Base, zone
    assert_equal "Emerald_Wilds", zone.id
  end

  it "should return nil zone for unknown region" do
    region = Hytale::Client::Zone::Region.new("Unknown_Region")

    assert_nil region.zone
  end

  it "should map Zone1 regions to Emerald_Wilds" do
    ["Zone1_Spawn", "Zone1_Tier1", "Zone1_Tier2", "Zone1_Tier3"].each do |id|
      region = Hytale::Client::Zone::Region.new(id)

      assert_equal "Emerald_Wilds", region.zone.id
    end
  end

  it "should map Zone2 regions to Howling_Sands" do
    region = Hytale::Client::Zone::Region.new("Zone2_Tier1")

    assert_equal "Howling_Sands", region.zone.id
  end
end
