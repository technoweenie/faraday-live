# frozen_string_literal: true

# Examples for an adapter and http method with a form request body
shared_examples 'a form post request' do |http_method, url_kind, adapter|
  before :all do
    @response = conn.public_send(http_method, 'post_request') do |req|
      req.body = {request_param: 'faraday live'}
    end
  end

  include_examples 'any request', http_method, {
    url_kind: url_kind,
  }

  include_examples 'any request expecting a response body',
    http_method, adapter, requesturi: '/requests/post_request',
    request_header: {
      'Content-Type' => 'application/x-www-form-urlencoded',
    }

  it 'sends request body' do
    expect(body['ContentLength']).to eq(26)
    expect(body['Form']['request_param']).to eq(['faraday live']),
      "got: #{body['Form'].inspect}"
  end
end
