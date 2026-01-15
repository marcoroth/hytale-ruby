# frozen_string_literal: true

require "test_helper"

class AssetsTest < Minitest::Spec
  before do
    skip_unless_game_installed
  end

  it "should return asset directories" do
    dirs = Hytale::Client::Assets.directories

    assert_instance_of Array, dirs
    assert_includes dirs, "Common/BlockTextures"
    assert_includes dirs, "Common/Icons"
    assert_includes dirs, "Server/Languages"
  end

  it "should list files in a directory" do
    files = Hytale::Client::Assets.list("Common/BlockTextures")

    assert_instance_of Array, files
    assert files.any?
    assert(files.all? { |f| f.start_with?("Common/BlockTextures/") })
  end

  it "should return empty array for nonexistent directory" do
    files = Hytale::Client::Assets.list("NonExistent/Directory")

    assert_empty files
  end

  it "should return all block textures" do
    textures = Hytale::Client::Assets.block_textures

    assert_instance_of Array, textures
    assert textures.any?
    assert_includes textures, "Rock_Stone"
  end

  it "should return all item icons" do
    icons = Hytale::Client::Assets.item_icons

    assert_instance_of Array, icons
    assert icons.any?
    assert_includes icons, "Weapon_Sword_Copper"
  end

  it "should return the block texture path" do
    path = Hytale::Client::Assets.block_texture_path("Rock_Stone")

    assert path.include?("BlockTextures")
    assert path.end_with?("Rock_Stone.png")
  end

  it "should not duplicate .png extension" do
    path = Hytale::Client::Assets.block_texture_path("Rock_Stone.png")

    assert path.end_with?("Rock_Stone.png")
    refute path.end_with?("Rock_Stone.png.png")
  end

  it "should return the item icon path" do
    path = Hytale::Client::Assets.item_icon_path("Weapon_Sword_Copper")

    assert path.include?("Icons")
    assert path.end_with?("Weapon_Sword_Copper.png")
  end

  it "should check if item icon exists" do
    exists = Hytale::Client::Assets.item_icon_exists?("Weapon_Sword_Copper")

    assert exists
  end

  it "should return false for nonexistent item icon" do
    exists = Hytale::Client::Assets.item_icon_exists?("NonExistent_Item")

    refute exists
  end

  it "should return the cache path" do
    path = Hytale::Client::Assets.cache_path

    assert path.include?("hytale")
    assert path.include?("assets")
  end

  it "should return the cached path for an asset" do
    path = Hytale::Client::Assets.cached_path("Common/BlockTextures/Rock_Stone.png")

    assert path.start_with?(Hytale::Client::Assets.cache_path)
    assert path.end_with?("Common/BlockTextures/Rock_Stone.png")
  end
end
