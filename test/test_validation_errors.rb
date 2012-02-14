require_relative 'helper'

class TestValidationErrors < MiniTest::Unit::TestCase

  class Car
    include MiniMongo::Document

    def validate
      add_error(:model, :required) if self["model"].blank?
      add_error(:model, :invalid) if self["model"] =~ /time/
    end
  end

  def test_validate
    car = Car.new
    refute car.valid?
    assert_includes car.errors, {field: "model", code: :required}

    car["model"] = "DeLorean time machine"
    refute car.valid?
    assert_includes car.errors, {field: "model", code: :invalid}

    car["model"] = "DeLorean"
    assert car.valid?
    assert car.errors.empty?
  end
end
