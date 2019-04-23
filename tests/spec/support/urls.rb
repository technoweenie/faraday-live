module FaradayURLs
  def self.test_server(kind, path = nil)
    return test_https_server(path) if kind == :https
    test_http_server(path)
  end

  def self.test_http_server(path = nil)
    @test_http_server ||= "http://#{ENV['HTTP_HOST']}"
    "#{@test_http_server}/#{path}"
  end

  def self.test_https_server(path = nil)
    @test_https_server ||= "https://#{ENV['HTTP_HOST']}"
    "#{@test_https_server}/#{path}"
  end
end
