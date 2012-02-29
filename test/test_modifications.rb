require_relative 'helper'

class TestModifications < MiniTest::Unit::TestCase

  class Store
    include MiniMongo::Document
  end

  def test_instance_modifiers
    store = Store.new(name: "Leftorium", address: {city: "Springfield"}, products: ["can opener", "roadster"], status: 10)
    store.insert!

    # set
    store.mod! do
      set("address.state", "?")
      set("address.zip", 12345)
    end
    store.reload
    assert_equal "?", store["address.state"]
    assert_equal 12345, store["address.zip"]

    # inc
    assert store.mod! { inc("sales", 23) }
    assert_equal 23, store.reload["sales"]
    assert store.mod! { inc("sales", -20) }
    assert_equal 3, store.reload["sales"]

    # unset
    assert store.mod! { unset("address.state", "address.zip") }
    store.reload
    assert !store.has_key?("address.state")
    assert !store.has_key?("address.zip")

    # push
    assert store.mod! { push("products", "shirt") }
    assert_includes store.reload["products"], "shirt"

    # pushAll
    assert store.mod! { push_all("products", "shotglass", "scissors", "shirt") }
    store.reload
    assert_includes store["products"], "shotglass"
    assert_includes store["products"], "scissors"
    assert store["products"].count { |p| p == "shirt" } == 2

    # pull
    assert store.mod! { pull("products", "scissors") }
    refute_includes store.reload["products"], "scissors"

    # pullAll
    assert store.mod! { pull_all("products", "shirt", "shotglass") }
    store.reload
    refute_includes store["products"], "shirt"
    refute_includes store["products"], "shotglass"

    # addToSet
    assert store.mod! { add_to_set("products", "mugs") }
    assert_includes store.reload["products"], "mugs"

    assert store.mod! { add_to_set("products", "mugs") }
    assert store.reload["products"].count { |p| p == "mugs" } == 1

    assert store.mod! { add_to_set("products", [1, 2]) }
    assert_includes store.reload["products"], [1, 2]

    # addToSet w/ $each
    assert store.mod! { add_to_set("products", ["bells", "whistles"], true) }
    store.reload
    assert_includes store["products"], "bells"
    assert_includes store["products"], "whistles"

    # pop
    assert store.mod! { pop("products", 1) }
    assert_equal ["can opener", "roadster", "mugs", [1, 2], "bells"], store.reload["products"]

    assert store.mod! { pop("products", -1) }
    assert_equal ["roadster", "mugs", [1, 2], "bells"], store.reload["products"]

    # rename
    store.mod! { rename("address", "location") }
    assert_equal "Springfield", store.reload["location.city"]

    # bit
    store.mod! { bit("status", {and: 2}) }
    assert_equal 2, store.reload["status"]

    store.mod! { bit("status", {or: 5}) }
    assert_equal 7, store.reload["status"]

    store.mod! { bit("status", {and: 3, or: 8}) }
    assert_equal 11, store.reload["status"]

    assert_raises(MiniMongo::ModifierUpdateError) { Store.new.mod!(strict: true) { set("a", "b") } }
    assert_equal 0, Store.new.mod!(strict: false) { set("a", "b") }
    assert_equal 0, Store.new.mod! { set("a", "b") }
  end

  def test_modifiers
    query = {_id: "Leftorium"}
    Store.mod!(query, {upsert: true}) do
      set("address.city", "Springfield")
      add_to_set("products", ["can opener", "roadster"], true)
      set("status", 10)
    end

    store = Store.find_one(query)
    store.reload

    # set
    Store.mod!(query) do
      set("address.state", "?")
      set("address.zip", 12345)
    end
    store.reload
    assert_equal "?", store["address.state"]
    assert_equal 12345, store["address.zip"]

    # inc
    assert Store.mod!(query) { inc("sales", 23) }
    assert_equal 23, store.reload["sales"]
    assert Store.mod!(query) { inc("sales", -20) }
    assert_equal 3, store.reload["sales"]

    # unset
    assert Store.mod!(query) { unset("address.state", "address.zip") }
    store.reload
    assert !store.has_key?("address.state")
    assert !store.has_key?("address.zip")

    # push
    assert Store.mod!(query) { push("products", "shirt") }
    assert_includes store.reload["products"], "shirt"

    # pushAll
    assert Store.mod!(query) { push_all("products", "shotglass", "scissors", "shirt") }
    store.reload
    assert_includes store["products"], "shotglass"
    assert_includes store["products"], "scissors"
    assert store["products"].count { |p| p == "shirt" } == 2

    # pull
    assert Store.mod!(query) { pull("products", "scissors") }
    refute_includes store.reload["products"], "scissors"

    # pullAll
    assert Store.mod!(query) { pull_all("products", "shirt", "shotglass") }
    store.reload
    refute_includes store["products"], "shirt"
    refute_includes store["products"], "shotglass"

    # addToSet
    assert Store.mod!(query) { add_to_set("products", "mugs") }
    assert_includes store.reload["products"], "mugs"

    assert Store.mod!(query) { add_to_set("products", "mugs") }
    assert store.reload["products"].count { |p| p == "mugs" } == 1

    assert Store.mod!(query) { add_to_set("products", [1, 2]) }
    assert_includes store.reload["products"], [1, 2]

    # addToSet w/ $each
    assert Store.mod!(query) { add_to_set("products", ["bells", "whistles"], true) }
    store.reload
    assert_includes store["products"], "bells"
    assert_includes store["products"], "whistles"

    # pop
    assert Store.mod!(query) { pop("products", 1) }
    assert_equal ["can opener", "roadster", "mugs", [1, 2], "bells"], store.reload["products"]

    assert Store.mod!(query) { pop("products", -1) }
    assert_equal ["roadster", "mugs", [1, 2], "bells"], store.reload["products"]

    # rename
    Store.mod!(query) { rename("address", "location") }
    assert_equal "Springfield", store.reload["location.city"]

    # bit
    Store.mod!(query) { bit("status", {and: 2}) }
    assert_equal 2, store.reload["status"]

    Store.mod!(query) { bit("status", {or: 5}) }
    assert_equal 7, store.reload["status"]

    Store.mod!(query) { bit("status", {and: 3, or: 8}) }
    assert_equal 11, store.reload["status"]

    # should raise error if no update (not inserted eg)
  end

  def test_skip_if_no_updates
    refute Store.new.mod! {  }
    refute Store.new.mod {  }
    refute Store.mod! {  }
    refute Store.mod {  }
  end

  def test_multi
    (a = Store.new(_id: "a", sales: 10)).insert!
    (b = Store.new(_id: "b", sales: 50)).insert!

    assert Store.mod({}, multi: true) { inc("sales", 32) }
    assert_equal 42, a.reload["sales"]
    assert_equal 82, b.reload["sales"]

    assert_equal 2, Store.mod!({}, multi: true) { inc("sales", -10) }
    assert_equal 32, a.reload["sales"]
    assert_equal 72, b.reload["sales"]

    assert Store.mod({_id: 'bad-id'}, multi: true) { inc("sales", 32) }
    assert_raises(MiniMongo::ModifierUpdateError) { Store.mod!({_id: 'bad-id'}, multi: true, strict: true) { inc("sales", 32) } }
    assert_equal 0, Store.mod!({_id: 'bad-id'}, multi: true, strict: false) { inc("sales", 32) }
    assert_equal 0, Store.mod!({_id: 'bad-id'}, multi: true) { inc("sales", 32) }
  end

  def test_safe
    Store.expects(:mod).with do |query, options, block|
      query == {field: "value"} && options == {upsert: true, safe: true}
    end
    Store.mod!({field: "value"}, {upsert: true}) { }

    store = Store.new
    store.expects(:mod).with do |options, block|
      options == {foo: "bar", safe: true}
    end
    store.mod!({foo: "bar"}) { }
  end
end
