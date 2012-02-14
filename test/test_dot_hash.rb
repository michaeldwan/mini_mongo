require_relative 'helper'

class TestDotHash < MiniTest::Unit::TestCase
  def setup
    @hash = MiniMongo::DotHash.new({
      "name" => "Michael",
      "location" => {"city" => "Boulder", "state" => "CO"},
      "pets" => ["kitty", "butters"],
      "jobs" => [
        {company: "snapjoy", languages: [{name: "ruby", cool: true}, {name: "javascript", cool: true}]},
        {company: "metromix", languages: [{name: "ruby"}]},
        {company: "clarity", languages: [{name: "c#", cool: false}]}
      ]
    })
  end

  def test_getting
    assert_equal "Michael", @hash.dot_get("name")
    assert_nil @hash["ssn"]
    assert_equal "Boulder", @hash.dot_get("location.city")
    assert_equal ["kitty", "butters"], @hash.dot_get("pets")
    @hash.dot_get("pets") << "reilly"
    assert_equal ["kitty", "butters", "reilly"], @hash.dot_get("pets")
    assert_nil @hash.dot_get("location.unknown")
  end

  def test_reaching_in
    assert_equal 3, @hash.dot_get("jobs").length
    assert_equal ["snapjoy", "metromix", "clarity"], @hash.dot_get("jobs.company")

    assert_equal [nil, nil, nil], @hash.dot_get("jobs.company.missing")

    assert_equal 4, @hash.dot_get("jobs.languages").length
    assert_includes @hash.dot_get("jobs.languages"), {"name" => "ruby", "cool" => true}
    assert_includes @hash.dot_get("jobs.languages"), {"name" => "javascript", "cool" => true}
    assert_includes @hash.dot_get("jobs.languages"), {"name" => "ruby"}
    assert_includes @hash.dot_get("jobs.languages"), {"name" => "c#", "cool" => false}

    assert_equal ["ruby", "javascript", "ruby", "c#"], @hash.dot_get("jobs.languages.name")
    assert_equal [true, true, nil, false], @hash.dot_get("jobs.languages.cool")
    assert_equal [nil, nil, nil, nil], @hash.dot_get("jobs.languages.missing")
  end

  def test_setting
    @hash.dot_set("favorite_color", "green")
    assert_equal "green", @hash.dot_get("favorite_color")
    @hash.dot_set("location.planet", "earth")
    assert_equal "earth", @hash.dot_get("location.planet")
  end

  def test_removing
    @hash.dot_delete("name")
    assert_nil @hash.dot_get("name")
    @hash.dot_delete("location.state")
    assert_nil @hash.dot_get("location.state")
    @hash.dot_delete("location")
    assert_nil @hash.dot_get("location")
    assert_nil @hash.dot_get("location.city")
    @hash.dot_delete("not_a_key")
  end
end
