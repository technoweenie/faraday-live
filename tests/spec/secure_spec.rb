# frozen_string_literal: true

describe 'Faraday with HTTPS server' do
  FaradayAdapters.each do |adapter|
    if ServerProtocols.https?
      it_behaves_like 'a connection making requests', :https, adapter
    end

    if ServerProtocols.proxy?
      it_behaves_like 'a proxied connection', adapter, {
        server: :https,
      }
    end
  end
end if ServerProtocols.test?(:https, :proxy)
