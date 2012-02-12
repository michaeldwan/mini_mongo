require_relative 'helper'

class TestDirty < MiniTest::Unit::TestCase

  class Car
    include MiniMongo::Document
  end

  def test_changes_and_dirty
    assert Car.new.dirty?
    assert_equal ["_id"], Car.new.changes.keys

    car = Car.new(make: "Ferrari", model: "F2012")
    assert car.dirty?
    assert_equal ({"_id" => [nil, car.to_oid], "make" => [nil, "Ferrari"], "model" => [nil, "F2012"]}), car.changes
    car["country"] = "Italy"
    assert_equal ({"_id" => [nil, car.to_oid], "make" => [nil, "Ferrari"], "model" => [nil, "F2012"], "country" => [nil, "Italy"]}), car.changes
    car.save!

    assert_equal ({}), car.changes
    assert !car.dirty?

    car["make"] = "McLaren"
    car["model"] = "MP4-27"
    assert car.dirty?
    assert_equal ({"make" => ["Ferrari", "McLaren"], "model" => ["F2012", "MP4-27"]}), car.changes
    car.save!

    assert !car.dirty?
    assert_equal ({}), car.changes

    car["model"] = nil
    car["color"] = "silver"
    assert car.dirty?
    assert_equal ({"model" => ["MP4-27", nil], "color" => [nil, "silver"]}), car.changes
    
    car.reload
    assert !car.dirty?
    assert car.changes.blank?

    car.remove!
    assert car.dirty?
    assert !car.changes.empty?
  end
end
