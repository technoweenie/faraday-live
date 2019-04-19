describe 'Faraday with HTTP server' do
  it_behaves_like 'a connection making requests',
    "http://#{ENV['HTTP_HOST']}", :net_http
end
