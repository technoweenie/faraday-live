# frozen_string_literal: true

describe 'Faraday with HTTP server' do
  FaradayAdapters.each do |adapter|
    it_behaves_like 'a connection making requests',
      "http://#{ENV['HTTP_HOST']}", adapter
  end
end if ServerProtocols.http?


describe 'Faraday with unverified HTTPS server' do
  FaradayAdapters.each do |adapter|
    it "no-ops (#{adapter})" do
      expect(adapter.key).to eq(adapter.key)
    end
  end
end if ServerProtocols.unverified_https?
