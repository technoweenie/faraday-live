# frozen_string_literal: true

# Examples for an adapter streaming a response body
shared_examples 'a request with a streaming body' do |url_kind, adapter, options|
  options ||= {}

  before :all do
    @data = []
    @sizes = []
    @response = conn.get('streaming', nil, options[:request_header]) do |req|
      req.params["delay"] = 1
      req.params["size"] = 200
      req.options.on_data = Proc.new do |chunk, size|
        #puts " * * * RECV #{size.inspect} * * *"
        #puts chunk
        #puts " * * * END RECV * * *"
        @data << chunk
        @sizes << size
      end
    end

    if @data.size > 0
      expect { @body = JSON.parse(@data.join) }.not_to raise_error
    end
  end

  include_examples 'any request', :get, {
    url_kind: url_kind,
    response_header: options[:response_header],
  }

  it 'receives empty response body' do
    expect(@response.body).to eq("")
  end

  it 'receives body/size chunks' do
    expect(@sizes.size).to eq(@data.size)

    case options[:proxy]
    when :https_auth_proxy, :https_proxy
      # test https proxy doesn't flush chunked response writes
      expect(@sizes.size).to eq(1)
    when :http_auth_proxy, :http_proxy
      if url_kind == :https
        expect(@sizes.size).to be > 1
      else
        # test https proxy doesn't flush chunked response writes
        expect(@sizes.size).to eq(1)
      end
    else
      expect(@sizes.size).to be > 1
    end
  end

  it 'receives increasing body sizes' do
    @sizes.inject(0) do |prev, num|
      expect(prev).to be < num
      num
    end
  end

  # From shared matcher:
  # "any request expecting a response body"
  # Can't use it here because streaming requests set no content-length
  it 'uses valid method' do
    expect(body['Method']).to eq("GET")
  end

  it 'accesses correct host' do
    expect(body['Host']).to eq(ENV['HTTP_HOST'])
  end

  it 'crafts correct request uri' do
    expect(body['RequestURI']).to eq('/requests/streaming?delay=1&size=200')
  end
end
