# frozen_string_literal: true

# Examples for all adapter accessing the given base url
shared_examples 'a connection making requests' do |base_url, adapter|
  before :all do
    conn_options = {
      headers: {
        'X-Faraday-Live' => '1',
        user_agent: "Faraday: #{adapter}",
      },
    }

    @conn = Faraday.new("#{base_url}/requests", conn_options) do |conn|
      conn.request :multipart
      conn.request :url_encoded
      conn.adapter(adapter.key)
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
    before :all do
      @response = conn.head('head_request')
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
    it_behaves_like 'a multipart request', :patch, adapter
  end if FaradayMethods.patch_method?(adapter)

  describe "with #{adapter}: #POST" do
    it_behaves_like 'a form post request', :post, adapter
    it_behaves_like 'a multipart request', :post, adapter
  end if FaradayMethods.post_method?(adapter)

  describe "with #{adapter}: #PUT" do
    it_behaves_like 'a form post request', :put, adapter
    it_behaves_like 'a multipart request', :put, adapter
  end if FaradayMethods.put_method?(adapter)

  describe "with #{adapter}: #TRACE" do
    it_behaves_like 'an idempotent request', :trace, adapter
  end if FaradayMethods.trace_method?(adapter)
end
