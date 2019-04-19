# frozen_string_literal: true

describe 'Faraday with HTTPS server', if: ServerProtocols.https? do
  FaradayAdapters.each do |adapter|
    it_behaves_like 'a connection making requests',
      "https://#{ENV['HTTP_HOST']}", adapter
  end
end
