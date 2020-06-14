struct Twitter::RateLimit
  include JSON::Serializable

  property limit : Int32
  property remaining : Int32
  property reset : Int64

  def initialize(@limit, @remaining, @reset)
  end

  def self.from_headers(headers : HTTP::Headers) : self
    self.new headers["x-rate-limit-limit"].to_i32, headers["x-rate-limit-remaining"].to_i32, headers["x-rate-limit-reset"].to_i64
  end
end
