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

  def test_prepare_document
    origianl = {species: "Cat", _id: 123}
    Animal.any_instance.expects(:prepare_document).with(origianl, false).returns({a:1})
    animal = Animal.new(origianl, false)
    assert_equal ({"a" => 1}), animal.to_hash
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

  def test_to_hash
    a = Animal.new(name: "Kitty")
    assert_equal a.document.to_hash, a.to_hash
  end

  def test_merge
    a = Animal.new(name: "Kitty")
    a.merge!(color: "black", hobbies: {sleeping: true, eating: true})
    assert a.dirty?
    assert_equal ({"_id" => [nil, a.id], "name" => [nil, "Kitty"], "color" => [nil, "black"], "hobbies.sleeping" => [nil, true], "hobbies.eating" => [nil, true]}), a.changes
    assert_equal ({"_id" => a.id, "name" => "Kitty", "color" => "black", "hobbies" => {"sleeping" => true, "eating" => true}}), a.to_hash
    a.save!
    assert !a.dirty?
    a.merge!(color: nil)
    assert a.dirty?
    assert_equal ({"color" => ["black", nil]}), a.changes
    assert_equal ({"_id" => a.id, "name" => "Kitty", "color" => nil, "hobbies" => {"sleeping" => true, "eating" => true}}), a.to_hash
  end

  def test_options_for_find
    Animal.collection.expects(:find).with do |query, options|
      options[:sort] == [[:a, 1], [:b, -1]]
    end

    Animal.find({}, {sort: {a: 1, b: -1}})
  end

  def test_distinct
    Animal.new(name: 'kitty', color: 'black').insert!
    Animal.new(name: 'butters', color: 'yellow').insert!
    Animal.new(name: 'dino', color: 'purple').insert!
    Animal.new(name: 'kitty', color: 'black').insert!
    Animal.new(name: 'reilly', color: 'black').insert!

    assert_equal %w(kitty butters dino reilly), Animal.distinct(:name)
    assert_equal %w(kitty reilly), Animal.distinct(:name, color: 'black')
  end

  def test_query
    Animal.expects(:options_for_find).returns([{a: 1}, {b: 2}])

    query = Animal.query({a: 'b'})
    assert_equal ({a: 1}), query
  end
end
