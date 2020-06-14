require "./models"

module Twitter
  struct Errors
    include JSON::Serializable
    property errors : Array(Twitter::Error)
    class ServerError < Exception; end
    class ClientError < Exception; end
  end

  struct Error
    include JSON::Serializable
    property message : String
    property code : Int32
  end

  struct Cursor
    include JSON::Serializable
    property next_cursor_str : String
    property previous_cursor_str : String
  end

  module WithCursor
    property next_cursor_str : String
    property previous_cursor_str : String
  end

  class Response::IDs
    include JSON::Serializable
    include WithCursor
    property ids : Array(Int64)
  end

  class Response::Users < Array(Twitter::Models::User)
  end

  class Response::RateLimitStatus
    include JSON::Serializable
    property resources : Twitter::Models::ResourcesRateLimitStatus

    def users_lookup
      resources.users.lookup
    end

    def followers_ids
      resources.followers.ids
    end
  end
end