RSpec.describe 'Faraday with HTTPS server' do
  it_behaves_like 'a connection making requests',
    "https://#{ENV['HTTP_HOST']}", :net_http
end
