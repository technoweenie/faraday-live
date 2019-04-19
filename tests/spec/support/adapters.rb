# frozen_string_literal: true

class FaradayAdapters
  def self.each(&block)
    adapters.each(&block)
  end

  def self.adapters
    @adapters ||= adapters!
  end

  def self.adapters!
    if !(adapters = explicit_adapters).empty?
      return adapters
    end

    adapters = [
      :net_http, :net_http_persistent,
      :excon, :typhoeus, :httpclient,
      :em_synchrony, :em_http,
    ]

    unless defined?(JRUBY_VERSION)
      adapters << :patron
    end

    adapters
  end

  def self.explicit_adapters
    ENV['FARADAY_ADAPTER'].to_s.split(',').map! do |key|
      key.strip!
      key.downcase!
      key.to_sym
    end
  end
end
