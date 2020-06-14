require "./models"

module Twitter
  class ServerError < Exception; end

  class ClientError < Exception; end

  struct Error
    include JSON::Serializable
    property error : String
  end

  class Response::IDs
    include JSON::Serializable
    property next_cursor_str : String?
    property previous_cursor_str : String?
    property ids : Array(Int64)
  end

  class Response::Users < Array(Twitter::Models::User)
    property next_cursor_str : String?
    property previous_cursor_str : String?
  end

  class Response::User < Twitter::Models::User
  end

  class Response::DM
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
