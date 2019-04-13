require 'pp'
require 'bundler/setup'
Bundler.require

puts "ruby v#{RUBY_VERSION}"
puts "faraday v#{Faraday::VERSION}"

begin
  conn = Faraday.new url: "#{ENV['HTTP_URL']}/requests"
  res = conn.get('live')
  puts res.status
  puts res.body
rescue
  puts "#{$!.class} #{$!}"
end
