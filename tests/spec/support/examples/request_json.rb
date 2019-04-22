# frozen_string_literal: true

# Examples for an adapter and http method with a json request body
shared_examples 'a json request' do |http_method, adapter|
  before :all do
    @response = conn.public_send(http_method, 'json_request') do |req|
      req.headers[:content_type] = 'application/json'
      req.body = {request_param: ['faraday live']}.to_json
    end
  end

  include_examples 'any request', http_method
  include_examples 'any request expecting a response body',
    http_method, adapter, requesturi: '/requests/json_request'

  it 'sends form content' do
    expect(body['Header']['Content-Type']).to eq(["application/json"])
  end

  it 'sends request body' do
    expect(body['ContentLength']).to eq(34)
    expect(body['Form']['request_param']).to eq(['faraday live']),
      "got: #{body['Form'].inspect}"
  end
end
