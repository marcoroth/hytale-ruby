# frozen_string_literal: true

require "test_helper"

class BlockTypeTest < Minitest::Spec
  before do
    skip_unless_game_installed
    Hytale::Client::BlockType.reload!
  end

  it "should return all block types" do
    all = Hytale::Client::BlockType.all

    assert all.any?
    assert(all.all? { |b| b.is_a?(Hytale::Client::BlockType) })
  end

  it "should return the block type count" do
    count = Hytale::Client::BlockType.count

    assert count.positive?
    assert_equal Hytale::Client::BlockType.all.count, count
  end

  it "should find an existing block by id" do
    block = Hytale::Client::BlockType.find("Rock_Stone")

    assert_instance_of Hytale::Client::BlockType, block
    assert_equal "Rock_Stone", block.id
  end

  it "should return nil for nonexistent block" do
    block = Hytale::Client::BlockType.find("NonExistent_Block")

    assert_nil block
  end

  it "should filter blocks by category" do
    rocks = Hytale::Client::BlockType.where(category: "Rock")

    assert rocks.any?
    assert(rocks.all? { |b| b.category == "Rock" })
  end

  it "should return all categories" do
    categories = Hytale::Client::BlockType.categories

    assert_instance_of Array, categories
    assert_includes categories, "Rock"
    assert_includes categories, "Soil"
    assert_includes categories, "Wood"
  end

  it "should return all subcategories" do
    subcategories = Hytale::Client::BlockType.subcategories

    assert_instance_of Array, subcategories
  end

  it "should return the block id" do
    block = Hytale::Client::BlockType.new("Rock_Stone")

    assert_equal "Rock_Stone", block.id
  end

  it "should return the block name" do
    block = Hytale::Client::BlockType.new("Rock_Stone")

    assert_equal "Rock Stone", block.name
  end

  it "should extract the category from id" do
    block = Hytale::Client::BlockType.new("Rock_Stone_Cobble")

    assert_equal "Rock", block.category
  end

  it "should extract the subcategory from id" do
    block = Hytale::Client::BlockType.new("Rock_Stone_Cobble")

    assert_equal "Stone", block.subcategory
  end

  it "should detect state definitions" do
    normal = Hytale::Client::BlockType.new("Rock_Stone")
    state = Hytale::Client::BlockType.new("*Rock_Stone")

    refute normal.state_definition?
    assert state.state_definition?
  end

  it "should return base id without state prefix" do
    normal = Hytale::Client::BlockType.new("Rock_Stone")
    state = Hytale::Client::BlockType.new("*Rock_Stone")

    assert_equal "Rock_Stone", normal.base_id
    assert_equal "Rock_Stone", state.base_id
  end

  it "should return the texture name" do
    block = Hytale::Client::BlockType.new("Rock_Stone")

    assert_equal "Rock_Stone.png", block.texture_name
  end

  it "should return the texture path" do
    block = Hytale::Client::BlockType.new("Rock_Stone")
    path = block.texture_path

    assert path.include?("BlockTextures")
    assert path.end_with?(".png")
  end

  it "should check if texture exists for known block" do
    block = Hytale::Client::BlockType.find("Rock_Stone")

    assert block.texture_exists? if block
  end

  it "should fall back to variant texture" do
    # Soil_Grass doesn't exist but Soil_Grass_Sunny does
    block = Hytale::Client::BlockType.new("Soil_Grass")

    return unless block.texture_exists?

    assert block.texture_path.include?("Soil_Grass")
  end

  it "should format to_s with name" do
    block = Hytale::Client::BlockType.new("Rock_Stone")

    assert_equal "BlockType: Rock Stone", block.to_s
  end

  it "should format inspect with id" do
    block = Hytale::Client::BlockType.new("Rock_Stone")

    assert_equal '#<Hytale::Client::BlockType id="Rock_Stone">', block.inspect
  end

  it "should convert to a hash" do
    block = Hytale::Client::BlockType.new("Rock_Stone")
    hash = block.to_h

    assert_equal "Rock_Stone", hash[:id]
    assert_equal "Rock", hash[:category]
    assert_equal "Rock Stone", hash[:name]
    assert hash.key?(:texture_path)
  end

  it "should compare blocks by id" do
    block1 = Hytale::Client::BlockType.new("Rock_Stone")
    block2 = Hytale::Client::BlockType.new("Rock_Stone")
    block3 = Hytale::Client::BlockType.new("Soil_Grass")

    assert_equal block1, block2
    refute_equal block1, block3
  end

  it "should have equal hash codes for equal blocks" do
    block1 = Hytale::Client::BlockType.new("Rock_Stone")
    block2 = Hytale::Client::BlockType.new("Rock_Stone")

    assert_equal block1.hash, block2.hash
  end

  it "should return all textures" do
    textures = Hytale::Client::BlockType.all_textures

    assert_instance_of Array, textures
    assert textures.any?
  end
end
