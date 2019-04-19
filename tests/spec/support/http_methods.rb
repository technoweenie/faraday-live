# frozen_string_literal: true

class FaradayMethods
  ALL_METHODS = [
    :connect, :delete, :get, :head, :options, :patch, :post, :put, :trace,
  ].freeze

  ALL_METHODS.each do |m|
    mname = "#{m}_method?"
    self.class.define_method(mname) do |adapter|
      return false unless http_methods.include?(m)
      return true unless adapter.respond_to?(mname)
      adapter.public_send(mname)
    end
  end

  def self.each(&block)
    http_methods.each(&block)
  end

  def self.http_methods
    @http_methods ||= Set.new(http_methods!)
  end

  def self.http_methods!
    methods = explicit_methods
    return methods unless methods.empty?
    ALL_METHODS
  end

  def self.explicit_methods
    ENV['FARADAY_METHOD'].to_s.split(',').map! do |key|
      key.strip!
      key.downcase!
      key.to_sym
    end
  end
end
