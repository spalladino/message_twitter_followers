require "./rate_limit"
require "./responses"

module Twitter::API
  def followers_ids(options = {} of String => String) : {Twitter::Response::IDs, RateLimit}
    response = get("followers/ids", options)
    {Twitter::Response::IDs.from_json(response.body), RateLimit.from_headers(response.headers)}
  end

  def users_lookup(user_ids : Array(Int64)) : {Twitter::Response::Users, RateLimit}
    response = post("users/lookup", {user_id: user_ids.map(&.to_s).join(",")})
    {Twitter::Response::Users.from_json(response.body), RateLimit.from_headers(response.headers)}
  end

  def rate_limit_status : {Twitter::Response::RateLimitStatus, RateLimit}
    response = get("application/rate_limit_status")
    {Twitter::Response::RateLimitStatus.from_json(response.body), RateLimit.from_headers(response.headers)}
  end

  def send_dm(recipient : Int64, message : String)
    response = post_json("direct_messages/events/new", {
      "event" => {
        "type"           => "message_create",
        "message_create" => {
          "target"       => {"recipient_id" => recipient.to_s},
          "message_data" => {"text" => message},
        },
      },
    })
  end

  def verify_credentials
    response = get("account/verify_credentials", {"include_entities" => "false"})
    {Twitter::Response::User.from_json(response.body), RateLimit.from_headers(response.headers)}
  end
end
