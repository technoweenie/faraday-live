# frozen_string_literal: true

shared_examples 'common request tests' do |url_kind, adapter, options|
  options ||= {}

  context "(#{adapter}) #GET request" do
    it_behaves_like 'an idempotent request', :get, url_kind, adapter,
      request_header: options[:request_header],
      response_header: options[:response_header]
  end if FaradayMethods.get_method?(adapter)

  context "(#{adapter}) #POST request" do
    it_behaves_like 'a form post request', :post, url_kind, adapter,
      request_header: options[:request_header],
      response_header: options[:response_header]
    it_behaves_like 'a multipart request', :post, url_kind, adapter,
      request_header: options[:request_header],
      response_header: options[:response_header]
  end if FaradayMethods.post_method?(adapter)
end
