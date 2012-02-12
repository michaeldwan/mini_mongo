require_relative 'helper'

class TestMiniMongo < MiniTest::Unit::TestCase
  def test_db
    assert_equal "mini_mongo_test", MiniMongo.db.name
    MiniMongo.db = Mongo::Connection.new["another_test_db"]
    assert_equal "another_test_db", MiniMongo.db.name
  end
end
