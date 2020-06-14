require "../spec_helper"
require "random"

def make_user(id)
  Twitter::Models::User.new(id.to_i64, "User #{id}", "Location #{id}", "Screen #{id}", false, false, true, Time.utc, id.to_i32, id.to_i32, id.to_i32, id.to_i32, id.to_i32)
end

describe Store::Client do
  it "manages followers" do
    db = Store::Client.new("test_#{Random.rand(UInt16).to_s}.db", 2_u32, 2_u32)
    db.create_schema

    db.insert_follower_ids([10_i64, 20_i64, 30_i64, 40_i64, 50_i64])
    db.unknown_followers_all.should eq([10_i64, 20_i64, 30_i64, 40_i64, 50_i64])

    db.update_followers_data([make_user(10), make_user(20), make_user(30)])
    db.unknown_followers_all.should eq([40_i64, 50_i64])

    db.unmessaged_followers_all.should eq([{30_i64, "User 30"}, {20_i64, "User 20"}, {10_i64, "User 10"}])
    db.mark_as_messaged([20_i64, 30_i64])
    db.unmessaged_followers_all.should eq([{10_i64, "User 10"}])
    db.mark_as_messaged([10_i64])
    db.unmessaged_followers_all.should eq([] of {Int64, String})
  ensure
    if db
      db.close
      db.terminate!
    end
  end

  it "manages cursors" do
    db = Store::Client.new("test_#{Random.rand(UInt16).to_s}.db", 2_u32, 2_u32)
    db.create_schema

    db.set_cursor "foo", "foo1"
    db.set_cursor "foo", "foo2"
    db.set_cursor "bar", "bar1"

    db.get_cursor("foo").should eq("foo2")
    db.get_cursor("bar").should eq("bar1")
    db.get_cursor("baz").should eq(nil)
  ensure
    if db
      db.close
      db.terminate!
    end
  end
end
