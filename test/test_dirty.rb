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

  def test_removing_a_subdocument
      car = Car.new({
        name: "R8",
        models: {
          v8: {cost: 123.45},
          v10: {cost: 456.78}
        }
      })

      car.save!

      car.snapshot

      car["models"].delete("v10")

      assert_includes car.changes.keys, "models.v10"
      refute_includes car.changes.keys, "models.v10.cost"

      assert_equal ({"cost" => 456.78}), car.changes["models.v10"][0]
      assert_nil car.changes["models.v10"][1]
  end
end
