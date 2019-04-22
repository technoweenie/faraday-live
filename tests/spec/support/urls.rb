module FaradayURLs
  def self.test_http_server
    @test_http_server ||= "http://#{ENV['HTTP_HOST']}"
  end

  def self.test_https_server
    @test_https_server ||= "https://#{ENV['HTTP_HOST']}"
  end
end
