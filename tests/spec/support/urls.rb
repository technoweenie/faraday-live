module FaradayURLs
  def self.test_server(kind, path = nil)
    case kind
    when :https then test_https_server(path)
    when :http then test_http_server(path)
    when :proxy then test_proxy_server(path)
    else
      raise "Unknown url kind: #{kind.inspect}"
    end
  end

  def self.test_http_server(path = nil)
    @test_http_server ||= "http://#{ENV['HTTP_HOST']}"
    "#{@test_http_server}/#{path}"
  end

  def self.test_https_server(path = nil)
    @test_https_server ||= "https://#{ENV['HTTP_HOST']}"
    "#{@test_https_server}/#{path}"
  end

  def self.test_proxy_server(path = nil)
    @test_proxy_server ||= "http://#{ENV['PROXY_HOST']}"
    "#{@test_proxy_server}/#{path}"
  end
end
