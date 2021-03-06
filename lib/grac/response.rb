require 'oj'
require 'forwardable'
require_relative './exception'

module Grac
  class Response
    extend Forwardable

    def_delegator :@response, :body
    def_delegator :@response, :code
    def_delegator :@response, :effective_url
    def_delegator :@response, :headers
    def_delegator :@response, :return_message

    def initialize(typhoeus_response)
      @response    = typhoeus_response
    end

    def content_type
      @response.headers["Content-Type"]
    end

    def json_content?
      !content_type.nil? && content_type.match('application/json')
    end

    def parsed_json
      Oj.load(body)
    rescue Oj::ParseError, EncodingError
      raise Exception::InvalidContent.new(body, 'json')
    end

    def parsed_or_raw_body
      return body unless json_content?

      begin
        parsed_json
      rescue Exception::InvalidContent
        body
      end
    end
  end
end
