module FaradayURLs
  def self.server(kind, arg = nil)
    if respond_to?("#{kind}_server")
      return public_send("#{kind}_server", arg)
    end
    raise "Unknown url kind: #{kind.inspect}"
  end

  def self.http_server(path = nil)
    "http://#{ENV['HTTP_HOST']}/#{path}"
  end

  def self.https_server(path = nil)
    "https://#{ENV['HTTP_HOST']}/#{path}"
  end

  def self.http_proxy_server(auth = nil)
    auth += "@" if auth
    "http://#{auth}#{ENV['PROXY_HOST']}:8080"
  end

  def self.http_auth_proxy_server(auth = nil)
    auth += "@" if auth
    "http://#{auth}#{ENV['PROXY_HOST']}:9080"
  end

  def self.https_proxy_server(auth = nil)
    auth += "@" if auth
    "http://#{auth}#{ENV['PROXY_HOST']}:8443"
  end

  def self.https_auth_proxy_server(auth = nil)
    auth += "@" if auth
    "http://#{auth}#{ENV['PROXY_HOST']}:9443"
  end
end
