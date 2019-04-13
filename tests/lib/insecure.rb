require 'pp'
require 'bundler/setup'
Bundler.require

puts __FILE__
puts "ruby v#{RUBY_VERSION}"
puts "faraday v#{Faraday::VERSION}"

begin
  puts "#{ENV['HTTP_URL']}/requests"
  conn = Faraday.new url: "#{ENV['HTTP_URL']}/requests"
  res = conn.get('live')
  puts res.status
  puts res.body
rescue
  puts "#{$!.class} #{$!}"
end

begin
  puts "#{ENV['HTTPS_URL']}/requests"
  conn = Faraday.new url: "#{ENV['HTTPS_URL']}/requests"
  res = conn.get('live')
  puts res.status
  puts res.body
rescue
  puts "#{$!.class} #{$!}"
end
