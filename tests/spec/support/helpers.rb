# frozen_string_literal: true

require 'digest'

module FaradayHelpers
  def sha256(s)
    Digest::SHA256.hexdigest(s.to_s)
  end
end
