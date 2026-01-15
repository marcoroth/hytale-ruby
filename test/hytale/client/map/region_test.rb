# frozen_string_literal: true

require "test_helper"

class RegionTest < Minitest::Spec
  before do
    @region = fixture_region
  end

  it "should define region constants" do
    assert_equal "HytaleIndexedStorage", Hytale::Client::Map::Region::MAGIC
    assert_equal 32, Hytale::Client::Map::Region::HEADER_SIZE
    assert_equal 1024, Hytale::Client::Map::Region::CHUNKS_PER_REGION
    assert_equal 4096, Hytale::Client::Map::Region::CHUNK_ALIGNMENT
  end

  it "should return the region file path" do
    assert @region.path.end_with?(".region.bin")
  end

  it "should return the region filename" do
    assert @region.filename.end_with?(".region.bin")
    assert @region.filename.match?(/^-?\d+\.-?\d+\.region\.bin$/)
  end

  it "should return integer coordinates" do
    assert_instance_of Integer, @region.x
    assert_instance_of Integer, @region.z
  end

  it "should have coordinates that match the filename" do
    match = @region.filename.match(/^(-?\d+)\.(-?\d+)\.region\.bin$/)

    assert_equal match[1].to_i, @region.x
    assert_equal match[2].to_i, @region.z
  end

  it "should return the file size in bytes" do
    assert @region.size.positive?
    assert_instance_of Integer, @region.size
  end

  it "should return the file size in megabytes" do
    assert @region.size_mb.positive?
    assert_instance_of Float, @region.size_mb
  end

  it "should return the modification time" do
    assert_instance_of Time, @region.modified_at
  end

  it "should return the header information" do
    header = @region.header

    assert_instance_of Hash, header
    assert header.key?(:version)
    assert header.key?(:chunk_count)
    assert header.key?(:index_table_size)
    assert header.key?(:data_start)
  end

  it "should have header version 1" do
    assert_equal 1, @region.header[:version]
  end

  it "should return the chunk count" do
    count = @region.chunk_count

    assert_instance_of Integer, count
    assert count >= 0
    assert count <= 1024
  end

  it "should check if a chunk exists at local coordinates" do
    chunks = @region.chunks

    return unless chunks.any?

    idx = chunks.keys.first
    local_x = idx % 32
    local_z = idx / 32

    assert @region.chunk_exists?(local_x, local_z)
  end

  it "should return false for invalid chunk coordinates" do
    refute @region.chunk_exists?(-1, 0)
    refute @region.chunk_exists?(0, -1)
    refute @region.chunk_exists?(32, 0)
    refute @region.chunk_exists?(0, 32)
  end

  it "should return chunks as a hash" do
    chunks = @region.chunks

    assert_instance_of Hash, chunks
  end

  it "should return Chunk objects in the chunks hash" do
    chunks = @region.chunks

    return unless chunks.any?

    assert(chunks.values.all? { |c| c.is_a?(Hytale::Client::Map::Chunk) })
  end

  it "should return chunk data at local coordinates" do
    chunks = @region.chunks

    return unless chunks.any?

    idx = chunks.keys.first
    local_x = idx % 32
    local_z = idx / 32

    chunk = @region.chunk_data(local_x, local_z)

    assert_instance_of Hytale::Client::Map::Chunk, chunk
  end

  it "should return nil for chunk data at invalid coordinates" do
    assert_nil @region.chunk_data(-1, 0)
    assert_nil @region.chunk_data(0, -1)
    assert_nil @region.chunk_data(32, 0)
    assert_nil @region.chunk_data(0, 32)
  end

  it "should return chunk at index" do
    chunks = @region.chunks

    return unless chunks.any?

    idx = chunks.keys.first
    chunk = @region.chunk_at_index(idx)

    assert_instance_of Hytale::Client::Map::Chunk, chunk
  end

  it "should return nil for chunk at invalid index" do
    assert_nil @region.chunk_at_index(-1)
    assert_nil @region.chunk_at_index(1024)
  end

  it "should iterate over each chunk" do
    count = 0

    @region.each_chunk do |chunk|
      assert_instance_of Hytale::Client::Map::Chunk, chunk
      count += 1
    end

    assert_equal @region.chunk_count, count
  end

  it "should return an enumerator for each_chunk without block" do
    enum = @region.each_chunk

    assert_instance_of Enumerator, enum
  end

  it "should return block types as an array" do
    types = @region.block_types

    assert_instance_of Array, types
  end

  it "should format to_s with region info" do
    str = @region.to_s

    assert str.include?("Region")
    assert str.include?(@region.x.to_s)
    assert str.include?(@region.z.to_s)
    assert str.include?("MB")
    assert str.include?("chunks")
  end

  it "should return the cache path" do
    path = @region.cache_path

    assert path.include?("hytale_cache")
    assert path.include?("regions")
    assert path.include?("region_#{@region.x}_#{@region.z}")
    assert path.end_with?(".png")
  end

  it "should include options in cache path" do
    path = @region.cache_path(scale: 2, detailed: true, shading: false)

    assert path.include?("2x")
    assert path.include?("detailed")
    assert path.include?("noshade")
  end

  it "should return false for cached after clearing cache" do
    @region.clear_cache!

    refute @region.cached?
  end
end
