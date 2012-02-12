require_relative 'helper'

class TestDocument < MiniTest::Unit::TestCase

  class Animal
    include MiniMongo::Document
  end

  def test_initialize
    Animal.collection.pk_factory.stubs(:new).returns(1)

    animal = Animal.new({species: "Cat"})
    assert_equal 1, animal.id
    assert animal.new?
    assert !animal.persisted?

    animal = Animal.new({species: "Cat", _id: 123})
    assert_equal 123, animal.id
    assert animal.new?
    assert !animal.persisted?

    animal = Animal.new({species: "Cat", _id: 123}, true)
    assert_equal 123, animal.id
    assert !animal.new?
    assert animal.persisted?
  end

  def test_getting_attributes
    animal = Animal.new({species: "Cat"})
    animal.document.expects(:dot_get).with("species").twice
    animal["species"]
    animal[:species]
  end

  def test_setting_attributes
    animal = Animal.new({species: "Cat"})
    animal.expects(:snapshot).twice
    animal.document.expects(:dot_set).with("name", "Butters").twice
    animal["name"] = "Butters"
    animal[:name] = "Butters"
  end

  def test_id
    animal = Animal.new({species: "Cat", _id: 123})
    assert_equal 123, animal.id

    animal = Animal.new({species: "Cat"})
    assert_equal animal["_id"], animal.id
  end

  def test_equality
    a = Animal.new
    assert_equal a, a
    assert_equal a, a.dup
    assert a != Animal.new

    a.insert!
    assert_equal a, Animal.find_one(a.id)
  end
end
