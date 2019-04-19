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

  def self.protocols
    @protocols ||= Set.new(protocols!)
  end

  def self.protocols!
    if !(protos = explicit_protocols).empty?
      return protos
    end

    [:http, :https]
  end

  def self.explicit_protocols
    ENV['SERVER_PROTOCOL'].to_s.split(',').map! do |key|
      key.strip!
      key.downcase!
      key.to_sym
    end
  end
end
