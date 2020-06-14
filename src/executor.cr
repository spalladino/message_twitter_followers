class Executor
  @db : Store::Client
  @twitter : Twitter::Client

  def initialize(@db, @twitter)
  end

  def get_followers
    cursor = @db.get_cursor("followers") || "-1"
    ids = [] of Int64
    while cursor != "0"
      response_ids, rate = @twitter.followers_ids({"cursor" => cursor})
      cursor = ids.next_cursor_str
      ids.concat(response_ids.ids)
      break if rate.remaining <= 1
    end

    if ids.length > 0
      @db.insert_follower_ids(ids)
      @db.set_cursor("followers", cursor)
    end
  end

  def lookup_followers
    chunk = [] of Int64
    users = [] of Twitter::Models::User

    @db.unknown_followers.each do |follower|
      chunk << follower
      if chunk.length == 100
        response_users, rate = @twitter.users_lookup(chunk)
        users.concat response_users.users
        chunk.clear
        break if rate.remaining <= 1
      end
    end

    if chunk.length > 0
      response_users, rate = @twitter.users_lookup(chunk)
      users.concat response_users.users
    end

    if users.length > 0
      @db.update_followers_data users
    end
  end
end
