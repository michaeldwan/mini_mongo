require_relative 'helper'

class TestPersistance < MiniTest::Unit::TestCase

  class Person
    include MiniMongo::Document

    attr_accessor :insert_callback

    def self.create_indexes
      collection.create_index(:name, {unique: true})
    end

    def validate
      add_error("name", :wtf_gimme_name) if self["name"].blank?
    end

    set_callback :insert do |object|
      object.insert_callback = true
    end
  end

  def setup
    super
    Person.create_indexes
  end

  def test_crud
    person = Person.new(name: "Michael", height: 71, location: {city: "Boulder"})
    assert person.new?
    assert !person.persisted?
    assert !person.removed?
    person.insert!
    
    assert person.insert_callback
    assert !person.new?
    assert person.persisted?
    assert !person.removed?

    assert_equal 1, Person.count

    person = Person.find_one(person.to_oid)
    assert !person.new?
    assert person.persisted?
    assert !person.removed?
    assert_equal "Michael", person["name"]
    assert_equal "Boulder", person["location.city"]

    person["brogrammer"] = false
    person.reload
    assert !person.new?
    assert person.persisted?
    assert !person.removed?


    person = Person.find_one(person.to_oid)
    person["height"] = 123
    person["job.company"] = "snapjoy"
    person["location"] = {"hemisphere" => "north"}
    person.update
    assert !person.new?
    assert person.persisted?
    assert !person.removed?


    person = Person.find_one(person.to_oid)
    assert_equal 123, person["height"]
    assert_equal "snapjoy", person["job.company"]
    assert_equal "north", person["location.hemisphere"]

    person["height"] = 456
    person.remove
    assert !person.new?
    assert !person.persisted?
    assert person.removed?
    assert_equal 0, Person.count
  end

  def test_save
    person = Person.new
    person.stubs(:persisted? => false)
    person.expects(:insert)
    person.save

    person.stubs(:persisted? => true)
    person.expects(:update)
    person.save

    person.stubs(:persisted? => false)
    person.expects(:insert!)
    person.save!

    person.stubs(:persisted? => true)
    person.expects(:update!)
    person.save!
  end

  def test_safe_methods
    person = Person.new
    person.expects(:insert).with(safe: true)
    person.insert!

    person.expects(:update).with(safe: true)
    person.update!

    person.expects(:remove).with(safe: true)
    person.remove!
  end

  def test_duplucate_key_error
    Person.create_indexes
    Person.new(name: "Michael").insert!
    assert_raises(MiniMongo::DuplicateKeyError) { Person.new(name: "Michael").insert! }
  end

  def test_validation_errors
    p = Person.new
    refute p.valid?
    assert_raises(MiniMongo::ValidationError) { p.insert }
    assert_raises(MiniMongo::ValidationError) { p.insert! }

    p["name"] = "Michael"
    p.save!

    p = Person.find_one(p.id)
    p["name"] = nil
    assert_raises(MiniMongo::ValidationError) { p.update }
    assert_raises(MiniMongo::ValidationError) { p.update! }

  end
end
