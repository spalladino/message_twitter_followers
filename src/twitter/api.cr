require "./rate_limit"
require "./responses"

module Twitter::API
  def followers_ids(options = {} of String => String) : { Twitter::Response::IDs, RateLimit }
    response = get("followers/ids", options)
    { Twitter::Response::IDs.from_json(response.body), RateLimit.from_headers(response.headers) }
  end

  def users_lookup(user_ids : Array(UInt64)) : { Twitter::Response::Users, RateLimit }
    response = post("users/lookup", { user_id: user_ids.map(&.to_s).join(",") })
    { Twitter::Response::Users.from_json(response.body), RateLimit.from_headers(response.headers) }
  end

  def rate_limit_status() : { Twitter::Response::RateLimitStatus, RateLimit }
    response = get("application/rate_limit_status")
    { Twitter::Response::RateLimitStatus.from_json(response.body), RateLimit.from_headers(response.headers) }
  end
end