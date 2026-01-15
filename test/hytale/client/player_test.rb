# frozen_string_literal: true

require "test_helper"

class PlayerTest < Minitest::Spec
  def sample_player_data
    {
      "Components" => {
        "Nameplate" => { "Text" => "TestPlayer" },
        "DisplayName" => { "DisplayName" => { "RawText" => "TestPlayer" } },
        "Transform" => {
          "Position" => { "X" => 100.5, "Y" => 64.0, "Z" => -200.25 },
          "Rotation" => { "Pitch" => 0.0, "Yaw" => 45.0, "Roll" => 0.0 },
        },
        "Velocity" => {
          "Velocity" => { "X" => 0.0, "Y" => -0.5, "Z" => 1.0 },
        },
        "EntityStats" => {
          "Stats" => {
            "Health" => { "Value" => 80.0, "Max" => 100.0 },
            "Stamina" => { "Value" => 50.0, "Max" => 100.0 },
          },
        },
        "Player" => {
          "GameMode" => "Survival",
          "Inventory" => {
            "Version" => 1,
            "ActiveHotbarSlot" => 0,
            "HotBar" => {
              "Capacity" => 10,
              "Items" => {
                "0" => { "Id" => "Tool_Pickaxe_Copper", "Quantity" => 1, "Durability" => 80.0,
                         "MaxDurability" => 100.0 },
                "1" => { "Id" => "Weapon_Sword_Copper", "Quantity" => 1 },
              },
            },
            "Storage" => {
              "Capacity" => 30,
              "Items" => {},
            },
            "Armor" => {
              "Capacity" => 4,
              "Items" => {
                "0" => { "Id" => "Armor_Copper_Head", "Quantity" => 1 },
              },
            },
          },
          "PlayerData" => {
            "World" => "default",
            "DiscoveredZones" => ["Zone1_Tier1", "Zone1_Tier2"],
          },
        },
        "PlayerMemories" => {
          "Memories" => [],
        },
      },
    }
  end

  before do
    @player = Hytale::Client::Player.new(sample_player_data, uuid: "test-uuid-1234")
  end

  it "should return the player uuid" do
    assert_equal "test-uuid-1234", @player.uuid
  end

  it "should return the player name" do
    assert_equal "TestPlayer", @player.name
  end

  it "should return the player position" do
    pos = @player.position

    assert_instance_of Hytale::Client::Player::Position, pos
    assert_equal 100.5, pos.x
    assert_equal 64.0, pos.y
    assert_equal(-200.25, pos.z)
  end

  it "should return the player rotation" do
    rot = @player.rotation

    assert_instance_of Hytale::Client::Player::Rotation, rot
    assert_equal 0.0, rot.pitch
    assert_equal 45.0, rot.yaw
    assert_equal 0.0, rot.roll
  end

  it "should return the player velocity" do
    vel = @player.velocity

    assert_instance_of Hytale::Client::Player::Vector3, vel
    assert_equal 0.0, vel.x
    assert_equal(-0.5, vel.y)
    assert_equal 1.0, vel.z
  end

  it "should return the game mode" do
    assert_equal "Survival", @player.game_mode
  end

  it "should return the current world" do
    assert_equal "default", @player.current_world
  end

  it "should return the discovered zones" do
    zones = @player.discovered_zones

    assert_instance_of Array, zones
    assert_includes zones, "Zone1_Tier1"
    assert_includes zones, "Zone1_Tier2"
  end

  it "should return the inventory" do
    inventory = @player.inventory

    assert_instance_of Hytale::Client::Player::Inventory, inventory
  end

  it "should return the entity stats" do
    stats = @player.stats

    assert_instance_of Hytale::Client::Player::EntityStats, stats
  end

  it "should return the player memories" do
    memories = @player.memories

    assert_instance_of Array, memories
  end

  it "should return the raw components hash" do
    components = @player.components

    assert_instance_of Hash, components
    assert components.key?("Player")
    assert components.key?("Transform")
  end

  it "should convert to a hash" do
    hash = @player.to_h

    assert_equal sample_player_data, hash
  end

  it "should handle empty components gracefully" do
    player = Hytale::Client::Player.new({}, uuid: "empty-uuid")

    assert_nil player.name
    assert_equal "empty-uuid", player.uuid
    assert_empty player.discovered_zones
  end

  it "should return the player data component" do
    data = @player.player_data

    assert_instance_of Hash, data
    assert_equal "Survival", data["GameMode"]
  end
end
