# frozen_string_literal: true

require "test_helper"

class ItemStorageTest < Minitest::Spec
  def sample_storage_data
    {
      "Id" => "HotBar",
      "Capacity" => 10,
      "Items" => {
        "0" => { "Id" => "Tool_Pickaxe_Copper", "Quantity" => 1 },
        "1" => { "Id" => "Weapon_Sword_Copper", "Quantity" => 1 },
        "5" => { "Id" => "Food_Apple", "Quantity" => 10 },
      },
    }
  end

  before do
    @storage = Hytale::Client::Player::ItemStorage.new(sample_storage_data)
  end

  it "should return the capacity" do
    assert_equal 10, @storage.capacity
  end

  it "should return the storage type" do
    assert_equal "HotBar", @storage.type
  end

  it "should not be empty when type is set" do
    refute @storage.empty?
  end

  it "should be empty when type is Empty" do
    storage = Hytale::Client::Player::ItemStorage.new({ "Id" => "Empty" })

    assert storage.empty?
  end

  it "should not be empty/simple when type is nil" do
    storage = Hytale::Client::Player::ItemStorage.new({})

    refute storage.empty?
    refute storage.simple?
  end

  it "should be simple when type is Simple" do
    storage = Hytale::Client::Player::ItemStorage.new({ "Id" => "Simple", "Capacity" => 10 })

    assert storage.simple?
  end

  it "should not be simple when type is Empty" do
    storage = Hytale::Client::Player::ItemStorage.new({ "Id" => "Empty" })

    refute storage.simple?
  end

  it "should return all items as an array" do
    items = @storage.items

    assert_instance_of Array, items
    assert_equal 3, items.count
    assert(items.all? { |i| i.is_a?(Hytale::Client::Player::Item) })
  end

  it "should assign correct slots to items" do
    items = @storage.items
    slots = items.map(&:slot)

    assert_includes slots, 0
    assert_includes slots, 1
    assert_includes slots, 5
  end

  it "should access items by slot index" do
    item = @storage[0]

    assert_instance_of Hytale::Client::Player::Item, item
    assert_equal "Tool_Pickaxe_Copper", item.id
    assert_equal 0, item.slot
  end

  it "should return nil for empty slots" do
    item = @storage[2]

    assert_nil item
  end

  it "should access items with integer keys" do
    item = @storage[5]

    assert_instance_of Hytale::Client::Player::Item, item
    assert_equal "Food_Apple", item.id
  end

  it "should convert to a hash" do
    hash = @storage.to_h

    assert_equal sample_storage_data, hash
  end

  it "should handle empty storage data" do
    empty = Hytale::Client::Player::ItemStorage.new({})

    assert_nil empty.capacity
    assert_nil empty.type
    assert_empty empty.items
  end

  it "should handle storage with no items" do
    data = { "Id" => "Storage", "Capacity" => 30, "Items" => {} }
    storage = Hytale::Client::Player::ItemStorage.new(data)

    assert_equal 30, storage.capacity
    assert_empty storage.items
  end
end
