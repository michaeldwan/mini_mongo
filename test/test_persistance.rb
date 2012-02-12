require_relative 'helper'

class TestPersistance < MiniTest::Unit::TestCase

  class Person
    include MiniMongo::Document

    attr_accessor :insert_callback

    def self.create_indexes
      collection.create_index(:name, {unique: true})
    end

    class << self
      attr_accessor :callbacks
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
    Person.callbacks = []

    person = Person.new(name: "Michael", height: 71, location: {city: "Boulder"})
    assert !person.persisted?
    person.insert
    
    assert person.insert_callback
    assert person.persisted?
    
    assert_equal 1, Person.count

    person = Person.find_one(person.to_oid)
    assert_equal "Michael", person["name"]
    assert_equal "Boulder", person["location.city"]

    assert !person.dirty?
    person["brogrammer"] = false
    assert person.dirty?
    person.reload
    assert !person.dirty?

    person = Person.find_one(person.to_oid)
    person["height"] = 123
    person["job.company"] = "snapjoy"
    person["location"] = {"hemisphere" => "north"}
    person.update

    person = Person.find_one(person.to_oid)
    assert_equal 123, person["height"]
    assert_equal "snapjoy", person["job.company"]
    assert_equal "north", person["location.hemisphere"]

    person["height"] = 456
    person.remove
    assert person.removed?
    assert !person.persisted?
    assert !person.dirty?
    assert_equal 0, Person.count
  end

  def test_duplucate_key_error
    Person.create_indexes
    Person.new(name: "Michael").insert!
    assert_raises(MiniMongo::DuplicateKeyError) { Person.new(name: "Michael").insert! }
  end
end
