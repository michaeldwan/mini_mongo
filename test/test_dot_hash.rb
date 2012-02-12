require_relative 'helper'

class TestDotHash < MiniTest::Unit::TestCase
  def setup
    @hash = MiniMongo::DotHash.new({
      "name" => "Michael",
      "location" => {"city" => "Boulder", "state" => "CO"},
      "pets" => ["kitty", "butters"]
    })
  end

  def test_getting
    assert_equal "Michael", @hash.dot_get("name")
    assert_nil @hash["ssn"]
    assert_equal "Boulder", @hash.dot_get("location.city")
    assert_equal ["kitty", "butters"], @hash.dot_get("pets")
    @hash.dot_get("pets") << "reilly"
    assert_equal ["kitty", "butters", "reilly"], @hash.dot_get("pets")
  end

  def test_setting
    @hash.dot_set("favorite_color", "green")
    assert_equal "green", @hash.dot_get("favorite_color")
    @hash.dot_set("location.planet", "earth")
    assert_equal "earth", @hash.dot_get("location.planet")
  end

  def test_removing
    @hash.dot_delete("name")
    assert_nil @hash.dot_get("name")
    @hash.dot_delete("location.state")
    assert_nil @hash.dot_get("location.state")
    @hash.dot_delete("location")
    assert_nil @hash.dot_get("location")
    assert_nil @hash.dot_get("location.city")
    @hash.dot_delete("not_a_key")
  end
end
