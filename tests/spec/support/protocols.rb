# frozen_string_literal: true

class ServerProtocols
  def self.http?
    protocols.include?(:http)
  end

  def self.https?
    protocols.include?(:https)
  end

  def self.unverified_https?
    protocols.include?(:unverified)
  end

  def self.http_proxy?
    protocols.include?(:proxy) || protocols.include?(:http_proxy)
  end

  def self.socks_proxy?
    protocols.include?(:proxy) || protocols.include?(:socks_proxy)
  end

  def self.test?(*protos)
    protos.any? { |p| protocols.include?(p) }
  end

  def self.protocols
    @protocols ||= Set.new(protocols!)
  end

  def self.protocols!
    if !(protos = explicit_protocols).empty?
      return protos
    end

    [:http, :https, :unverified, :proxy]
  end

  def self.explicit_protocols
    ENV['SERVER_PROTOCOL'].to_s.split(',').map! do |key|
      key.strip!
      key.downcase!
      key.to_sym
    end
  end
end
