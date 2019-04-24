module FaradayURLs
  def self.server(kind, path = nil)
    if respond_to?("#{kind}_server")
      return public_send("#{kind}_server", path)
    end
    raise "Unknown url kind: #{kind.inspect}"
  end

  def self.http_server(path = nil)
    @http_server ||= "http://#{ENV['HTTP_HOST']}"
    "#{@http_server}/#{path}"
  end

  def self.https_server(path = nil)
    @https_server ||= "https://#{ENV['HTTP_HOST']}"
    "#{@https_server}/#{path}"
  end

  def self.http_proxy_server(path = nil)
    @http_proxy_server ||= "http://#{ENV['PROXY_HOST']}:8080"
  end

  def self.http_auth_proxy_server(path = nil)
    @http_auth_proxy_server ||= "http://#{ENV['PROXY_HOST']}:9080"
  end

  def self.https_proxy_server(path = nil)
    @https_proxy_server ||= "http://#{ENV['PROXY_HOST']}:8443"
  end

  def self.https_auth_proxy_server(path = nil)
    @https_auth_proxy_server ||= "http://#{ENV['PROXY_HOST']}:9443"
  end
end
