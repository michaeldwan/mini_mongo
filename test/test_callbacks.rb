require_relative 'helper'

class TestCallbacks < MiniTest::Unit::TestCase

  class Person
    include MiniMongo::Document

    attr_accessor :initialize_callback
    attr_accessor :insert_callback
    attr_accessor :update_callback
    attr_accessor :save_callback
    attr_accessor :remove_callback

    set_callback :initialize do |object|
      object.initialize_callback = true
    end

    set_callback :insert do |object|
      object.insert_callback = true
    end

    set_callback :save do |object|
      object.save_callback = true
    end

    set_callback :update do |object|
      object.update_callback = true
    end

    set_callback :remove do |object|
      object.remove_callback = true
    end
  end

  def test_callbacks_on_initialize
    person = Person.new
    assert person.initialize_callback
    person.insert!
    person = Person.first
    refute person.initialize_callback
  end

  def test_callbacks_on_insert
    person = Person.new

    refute person.insert_callback
    refute person.save_callback
    refute person.update_callback
    refute person.remove_callback

    person.insert!

    assert person.insert_callback
    refute person.update_callback
    assert person.save_callback
    refute person.remove_callback
  end

  def test_callbacks_on_update
    Person.new.insert!
    person = Person.first

    refute person.insert_callback
    refute person.save_callback
    refute person.update_callback
    refute person.remove_callback

    person.update!

    refute person.insert_callback
    assert person.update_callback
    assert person.save_callback
    refute person.remove_callback
  end

  def test_callbacks_on_save_when_new
    person = Person.new

    refute person.insert_callback
    refute person.save_callback
    refute person.update_callback
    refute person.remove_callback

    person.save!

    assert person.insert_callback
    refute person.update_callback
    assert person.save_callback
    refute person.remove_callback
  end

  def test_callbacks_on_save_when_update
    Person.new.insert!
    person = Person.first

    refute person.insert_callback
    refute person.save_callback
    refute person.update_callback
    refute person.remove_callback

    person.save!

    refute person.insert_callback
    assert person.update_callback
    assert person.save_callback
    refute person.remove_callback
  end

  def test_callbacks_on_remove
    Person.new.insert!
    person = Person.first

    refute person.insert_callback
    refute person.save_callback
    refute person.update_callback
    refute person.remove_callback

    person.remove!

    refute person.insert_callback
    refute person.update_callback
    refute person.save_callback
    assert person.remove_callback
  end
end
