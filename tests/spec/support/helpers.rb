# frozen_string_literal: true

require 'digest'

module FaradayHelpers
  def sha256(s)
    Digest::SHA256.hexdigest(s.to_s)
  end

  def conn
    @conn
  end

  def response
    @response
  end

  def body
    JSON.parse(response.body)
  rescue JSON::ParserError
    puts response.body
    raise
  end
end
