# frozen_string_literal: true

# Examples for ALL responses from the server
shared_examples 'any request' do |http_method|
  {
    'Content-Type' => 'application/json',
  }.each do |key, value|
    it "returns #{key} response header" do
      expect(response.headers[key]).to eq(value)
    end
  end

  it 'returns response status' do
    expect(response.status).to eq(200)
  end
end

# Examples for all adapter accessing the given base url
shared_examples 'a connection making requests' do |base_url, adapter|
  let(:conn) do
    conn_options = {
      headers: {
        'X-Faraday-Live' => '1',
        user_agent: "Faraday: #{adapter}",
      },
    }

    Faraday.new("#{base_url}/requests", conn_options) do |conn|
      conn.request :url_encoded
      conn.adapter(adapter.key)
    end
  end

  let(:body) do
    begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      puts response.body
      raise
    end
  end

  describe "with #{adapter}: #CONNECT" do
    it_behaves_like 'an idempotent request', :connect, adapter
  end if FaradayMethods.connect_method?(adapter)

  describe "with #{adapter}: #DELETE" do
    it_behaves_like 'an idempotent request', :delete, adapter
    it_behaves_like 'a json request', :delete, adapter
  end if FaradayMethods.delete_method?(adapter)

  describe "with #{adapter}: #GET" do
    it_behaves_like 'an idempotent request', :get, adapter
    it_behaves_like 'a json request', :get, adapter
  end if FaradayMethods.get_method?(adapter)

  describe "with #{adapter}: #HEAD" do
    let(:response) do
      conn.head('test')
    end

    include_examples 'any request', :head

    it 'receives empty response body' do
      expect(response.headers[:content_length].to_i).to be > 0
      expect(response.body).to eq('')
    end
  end if FaradayMethods.head_method?(adapter)

  describe "with #{adapter}: #OPTIONS" do
    it_behaves_like 'an idempotent request', :options, adapter
  end if FaradayMethods.options_method?(adapter)

  describe "with #{adapter}: #PATCH" do
    it_behaves_like 'a form post request', :patch, adapter
  end if FaradayMethods.patch_method?(adapter)

  describe "with #{adapter}: #POST" do
    it_behaves_like 'a form post request', :post, adapter
  end if FaradayMethods.post_method?(adapter)

  describe "with #{adapter}: #PUT" do
    it_behaves_like 'a form post request', :put, adapter
  end if FaradayMethods.put_method?(adapter)

  describe "with #{adapter}: #TRACE" do
    it_behaves_like 'an idempotent request', :trace, adapter
  end if FaradayMethods.trace_method?(adapter)
end
