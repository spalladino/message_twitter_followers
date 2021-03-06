require "uri"
require "http/client"
require "oauth"
require "json"

require "./api"
require "./models"

module Twitter
  class Client
    HOST = "api.twitter.com"

    property access_token : String
    property access_token_secret : String
    property consumer_key : String
    property consumer_secret : String

    include Twitter::API

    def initialize(@consumer_key, @consumer_secret, @access_token, @access_token_secret)
      consumer = OAuth::Consumer.new(HOST, consumer_key, consumer_secret)
      access_token = OAuth::AccessToken.new(access_token, access_token_secret)
      @http_client = HTTP::Client.new(HOST, tls: true)
      consumer.authenticate(@http_client, access_token)
    end

    def get(path : String, params = {} of String => String)
      fullpath = "/1.1/#{path}.json"
      fullpath += "?#{to_query_string(params)}" unless params.empty?
      response = @http_client.get(fullpath)
      handle_response(response)
    end

    def post(path : String, form = {} of String => String)
      fullpath = "/1.1/#{path}.json"
      response = @http_client.post(fullpath, form: form)
      handle_response(response)
    end

    def post_json(path : String, object)
      fullpath = "/1.1/#{path}.json"
      response = @http_client.post(fullpath, headers: HTTP::Headers{"Content-Type" => "application/json"}, body: object.to_json)
      handle_response(response)
    end

    private def handle_response(response : HTTP::Client::Response)
      case response.status_code
      when 200..299
        response
      when 400..499
        message = Twitter::Error.from_json(response.body).error rescue "Unknown client error: #{response.body.presence || "[empty]"}"
        raise Twitter::ClientError.new(message)
      when 500
        raise Twitter::ServerError.new("Internal Server Error")
      when 502
        raise Twitter::ServerError.new("Bad Gateway")
      when 503
        raise Twitter::ServerError.new("Service Unavailable")
      when 504
        raise Twitter::ServerError.new("Gateway Timeout")
      else
        raise Twitter::ClientError.new("Unexpected response")
      end
    end

    private def to_query_string(hash : Hash)
      HTTP::Params.build do |form_builder|
        hash.each do |key, value|
          form_builder.add(key, value)
        end
      end
    end
  end
end
