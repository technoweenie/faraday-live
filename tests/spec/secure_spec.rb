# frozen_string_literal: true

describe 'Faraday with HTTPS server', if: ServerProtocols.https? do
  FaradayAdapters.each do |adapter|
    it_behaves_like 'a connection making requests',
      FaradayURLs.test_https_server, adapter
  end
end
