# frozen_string_literal: true

class FaradayAdapters
  def self.each(&block)
    adapters.each(&block)
  end

  def self.adapters
    @adapters ||= adapter_keys.map { |key| ADAPTERS[key] }.tap(&:compact!)
  end

  def self.adapter_keys
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
    ENV['TEST_ADAPTER'].to_s.split(',').map! do |key|
      key.strip!
      key.downcase!
      key.to_sym
    end
  end

  class Adapter
    attr_reader :key

    def initialize(key, *features)
      @key = key
      @features = Set.new(features)
    end

    def to_s
      @key.to_s
    end

    [
      :trace_method, # enables TRACE tests
      :connect_with_response_body, # enables CONNECT tests WITH response body
      :unverified_https_bug, # https://github.com/technoweenie/faraday-live/issues/4
      :https_proxy_bug, # https://github.com/technoweenie/faraday-live/issues/6
      :socks_proxy,
      :stream_response,
    ].each do |feature|
      define_method("#{feature}?") { @features.include?(feature) }
    end

    # enables CONNECT tests with or without response body
    def connect_method?
      @features.include?(:connect_method) ||
        @features.include?(:connect_with_response_body)
    end
  end

  ADAPTERS = {
    :em_http => Adapter.new(:em_http,
      :trace_method, :connect_with_response_body),

    :em_synchrony => Adapter.new(:em_synchrony),

    :excon => Adapter.new(:excon,
      :trace_method, :connect_method, :stream_response),

    :http => Adapter.new(:http),

    :httpclient => Adapter.new(:httpclient,
      :trace_method, :https_proxy_bug),

    :net_http_persistent => Adapter.new(:net_http_persistent,
      :trace_method, :connect_with_response_body),

    :net_http => Adapter.new(:net_http,
      :socks_proxy, :trace_method, :connect_with_response_body, :stream_response),

    :patron => Adapter.new(:patron,
      :unverified_https_bug),

    :typhoeus => Adapter.new(:typhoeus,
      :trace_method, :connect_with_response_body, :unverified_https_bug,
      :https_proxy_bug),
  }
end
