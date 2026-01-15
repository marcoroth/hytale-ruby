# frozen_string_literal: true

require "test_helper"

class HytaleTest < Minitest::Spec
  it "should return the client module" do
    assert_equal Hytale::Client, Hytale.client
  end

  it "should have a valid version number" do
    assert_match(/\A\d+\.\d+\.\d+/, Hytale::VERSION)
  end
end
