require_relative 'helper'

class TestSerialization < MiniTest::Unit::TestCase

  class Car
    include MiniMongo::Document
  end

  class Food
    include MiniMongo::Document

    def serializable_hash(options = {})
      out = to_hash
      if options && options[:yummy]
        out["good"] = true
      end
      out
    end
  end

  def test_serializable_hash
    car = Car.new(color: "red", wheels: 4)
    assert_equal ({"_id" => car.id, "color" => "red", "wheels" => 4}), car.serializable_hash
  end

  def test_json
    car = Car.new(color: "red", wheels: 4)
    assert_equal ({"_id" => car.id, "color" => "red", "wheels" => 4}), car.as_json
    assert_equal ({"car" => {"_id" => car.id, "color" => "red", "wheels" => 4}}), car.as_json(root: true)
    assert_equal JSON.generate({"color" => "red", "wheels" => 4, "_id" => car.id.to_s}), car.to_json
    assert_equal JSON.generate({"car" => {"color" => "red", "wheels" => 4, "_id" => car.id.to_s}}), car.to_json(root: true)

    car = Food.new(name: "pizza")
    assert_equal ({"_id" => car.id, "name" => "pizza"}), car.as_json
    assert_equal ({"food" => {"_id" => car.id, "name" => "pizza"}}), car.as_json(root: true)
    assert_equal ({"food" => {"_id" => car.id, "name" => "pizza", "good" => true}}), car.as_json(root: true, yummy: true)
    assert_equal ({"_id" => car.id, "name" => "pizza", "good" => true}), car.as_json(yummy: true)


    assert_equal JSON.generate({"food" => {"name" => "pizza", "_id" => car.id.to_s, "good" => true}}), car.to_json(root: true, yummy: true)
    assert_equal JSON.generate({"name" => "pizza", "_id" => car.id.to_s, "good" => true}), car.to_json(yummy: true)
  end
end
