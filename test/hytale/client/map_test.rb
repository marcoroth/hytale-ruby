# frozen_string_literal: true

require "test_helper"

class MapTest < Minitest::Spec
  before do
    @map = Hytale::Client::Map.new("/tmp/fake_save", world_name: "test_world")
  end

  it "should define map constants" do
    assert_equal 512, Hytale::Client::Map::REGION_SIZE
    assert_equal 32, Hytale::Client::Map::CHUNKS_PER_REGION
    assert_equal 16, Hytale::Client::Map::CHUNK_SIZE
  end

  it "should return the world path" do
    assert_equal "/tmp/fake_save", @map.world_path
  end

  it "should return the world name" do
    assert_equal "test_world", @map.world_name
  end

  it "should default world name to 'default'" do
    map = Hytale::Client::Map.new("/tmp/fake_save")

    assert_equal "default", map.world_name
  end

  it "should return the chunks path" do
    expected = "/tmp/fake_save/universe/worlds/test_world/chunks"

    assert_equal expected, @map.chunks_path
  end

  it "should return the resources path" do
    expected = "/tmp/fake_save/universe/worlds/test_world/resources"

    assert_equal expected, @map.resources_path
  end

  it "should return empty regions when no directory exists" do
    assert_empty @map.regions
  end

  it "should convert positive world coords to region coords" do
    assert_equal [0, 0], @map.world_to_region_coords(0, 0)
    assert_equal [0, 0], @map.world_to_region_coords(100, 200)
    assert_equal [0, 0], @map.world_to_region_coords(511, 511)
    assert_equal [1, 0], @map.world_to_region_coords(512, 0)
    assert_equal [1, 1], @map.world_to_region_coords(512, 512)
    assert_equal [2, 3], @map.world_to_region_coords(1024, 1536)
  end

  it "should convert negative world coords to region coords" do
    assert_equal [-1, -1], @map.world_to_region_coords(-1, -1)
    assert_equal [-1, -1], @map.world_to_region_coords(-100, -200)
    assert_equal [-1, -1], @map.world_to_region_coords(-512, -512)
    assert_equal [-2, -1], @map.world_to_region_coords(-513, -1)
    assert_equal [-2, -2], @map.world_to_region_coords(-513, -513)
  end

  it "should convert mixed world coords to region coords" do
    assert_equal [0, -1], @map.world_to_region_coords(100, -100)
    assert_equal [-1, 0], @map.world_to_region_coords(-100, 100)
  end

  it "should convert positive world coords to chunk local coords" do
    assert_equal [0, 0], @map.world_to_chunk_local_coords(0, 0)
    assert_equal [6, 12], @map.world_to_chunk_local_coords(100, 200)
    assert_equal [0, 0], @map.world_to_chunk_local_coords(512, 512)
    assert_equal [31, 31], @map.world_to_chunk_local_coords(511, 511)
  end

  it "should convert negative world coords to chunk local coords" do
    # -1 should be in chunk 31 (last chunk of region -1)
    assert_equal [31, 31], @map.world_to_chunk_local_coords(-1, -1)

    # -16 should be in chunk 31
    assert_equal [31, 31], @map.world_to_chunk_local_coords(-16, -16)

    # -17 should be in chunk 30
    assert_equal [30, 30], @map.world_to_chunk_local_coords(-17, -17)

    # -512 should be in chunk 0 of region -1
    assert_equal [0, 0], @map.world_to_chunk_local_coords(-512, -512)
  end

  it "should convert positive world coords to block local coords" do
    assert_equal [0, 0], @map.world_to_block_local_coords(0, 0)
    assert_equal [4, 8], @map.world_to_block_local_coords(100, 200)
    assert_equal [0, 0], @map.world_to_block_local_coords(16, 16)
    assert_equal [15, 15], @map.world_to_block_local_coords(15, 15)
  end

  it "should convert negative world coords to block local coords" do
    # -1 should be block 15 (last block of chunk)
    assert_equal [15, 15], @map.world_to_block_local_coords(-1, -1)

    # -16 should be block 0
    assert_equal [0, 0], @map.world_to_block_local_coords(-16, -16)

    # -17 should be block 15
    assert_equal [15, 15], @map.world_to_block_local_coords(-17, -17)
  end

  it "should return nil bounds when no regions exist" do
    assert_nil @map.bounds
  end

  it "should return empty markers when no file exists" do
    assert_empty @map.markers
  end

  it "should return nil time when no file exists" do
    assert_nil @map.time
  end

  it "should return zero total size when no regions exist" do
    assert_equal 0, @map.total_size
  end

  it "should return zero total size in MB when no regions exist" do
    assert_equal 0.0, @map.total_size_mb
  end

  it "should return empty block types when no regions exist" do
    assert_empty @map.block_types
  end

  it "should show 'No regions explored' in ASCII when empty" do
    assert_equal "No regions explored", @map.to_ascii
  end

  it "should return the cache path" do
    path = @map.cache_path

    assert path.include?("hytale_cache")
    assert path.include?("test_world")
    assert path.end_with?(".png")
  end

  it "should include options in cache path" do
    path = @map.cache_path(scale: 2, detailed: true, shading: false)

    assert path.include?("2x")
    assert path.include?("detailed")
    assert path.include?("noshade")
  end

  it "should return false for cached when no cache exists" do
    refute @map.cached?
  end

  it "should return fixture regions as an array" do
    map = fixture_map

    assert_instance_of Array, map.regions
  end

  it "should return Region objects from fixture" do
    map = fixture_map

    assert(map.regions.all? { |r| r.is_a?(Hytale::Client::Map::Region) })
  end

  it "should find region at coordinates in fixture" do
    map = fixture_map
    region = map.regions.first
    found = map.region_at(region.x, region.z)

    assert_equal region.x, found.x
    assert_equal region.z, found.z
  end

  it "should return nil for nonexistent region in fixture" do
    map = fixture_map
    found = map.region_at(9999, 9999)

    assert_nil found
  end

  it "should find region at world coordinates in fixture" do
    map = fixture_map
    region = map.regions.first

    world_x = (region.x * 512) + 100
    world_z = (region.z * 512) + 100

    found = map.region_at_world(world_x, world_z)

    assert_equal region.x, found.x
    assert_equal region.z, found.z
  end

  it "should return bounds hash from fixture" do
    map = fixture_map
    bounds = map.bounds

    assert_instance_of Hash, bounds
    assert bounds.key?(:min_x)
    assert bounds.key?(:max_x)
    assert bounds.key?(:min_z)
    assert bounds.key?(:max_z)
    assert bounds.key?(:width)
    assert bounds.key?(:height)
  end

  it "should return positive total size from fixture" do
    map = fixture_map

    assert map.total_size.positive?
  end

  it "should return positive total size in MB from fixture" do
    map = fixture_map

    assert map.total_size_mb.positive?
  end

  it "should render ASCII map with legend from fixture" do
    map = fixture_map
    ascii = map.to_ascii

    refute_equal "No regions explored", ascii
    assert ascii.include?("Legend:")
  end
end
