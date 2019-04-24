# frozen_string_literal: true

# runs tests for an adapter and http method with no request body
shared_examples 'an idempotent request' do |http_method, url_kind, adapter, options|
  options ||= {}

  before :all do
    @response = conn.public_send(http_method, 'idempotent_request')
  end

  include_examples 'any request', http_method, {
    url_kind: url_kind,
    response_header: options[:response_header],
  }

  if http_method != :connect || adapter.connect_with_response_body?
    include_examples 'any request expecting a response body',
      http_method, adapter, {
      requesturi: '/requests/idempotent_request',
      request_header: options[:request_header],
    }

    it 'sends no body' do
      expect(body['ContentLength']).to eq(0)
      expect(body['Form']).to eq({})
    end
  end
end
