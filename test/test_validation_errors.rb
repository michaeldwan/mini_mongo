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
    assert_includes car.errors, ["model", :required]
    I18n.expects(:t).with("test_validation_errors/car.validations.model.required").returns("biff")
    assert_includes car.error_messages, ["model", "biff"]

    car["model"] = "DeLorean time machine"
    refute car.valid?
    assert_includes car.errors, ["model", :invalid]
    I18n.expects(:t).with("test_validation_errors/car.validations.model.invalid").returns("zap")
    assert_includes car.error_messages, ["model", "zap"]

    car["model"] = "DeLorean"
    assert car.valid?
    assert car.error_messages.empty?
  end
end
