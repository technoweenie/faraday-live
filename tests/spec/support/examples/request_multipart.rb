# frozen_string_literal: true

dir = File.dirname(__FILE__)
MULTIPART_FILE1 = File.join(dir, 'connection.rb')
MULTIPART_FILE2 = File.join(dir, 'request_idempotent.rb')
MULTIPART_FILE3 = File.join(dir, 'request.rb')

# Examples for an adapter and http method with a multipart request body
shared_examples 'a multipart request' do |http_method, url_kind, adapter, options|
  options ||= {}

  before :all do
    @response = conn.public_send(http_method, '/multipart') do |req|
      req.headers[:content_type] = 'multipart/form-data'
      req.body = {
        key: 'value',
        file1: Faraday::UploadIO.new(MULTIPART_FILE1, 'text/x-ruby'),
        file2: Faraday::UploadIO.new(MULTIPART_FILE2, 'text/x-ruby', nil,
          'Content-Disposition' => 'form-data; foo=1'),
        file3: Faraday::UploadIO.new(MULTIPART_FILE3, 'text/x-ruby', nil,
          'Content-Id' => '123'),
      }
    end
  end

  include_examples 'any request', http_method, {
    url_kind: url_kind,
    response_header: options[:response_header],
  }

  include_examples 'any request expecting a response body',
    http_method, adapter, requesturi: '/multipart',
    request_header: {
      'Content-Type' => /\Amultipart\/form\-data\; boundary\=/,
    }.update(options[:request_header] || {})

  it 'sends request body' do
    expect(body['ContentLength']).to be > 0
  end

  it 'sends all form values' do
    expect(form_parts.size).to eq(4)
  end

  it_behaves_like 'a multipart form value', 0, 'key', 'value'

  it_behaves_like 'a multipart form file', 1, 'file1', MULTIPART_FILE1,
    'Content-Transfer-Encoding' => 'binary',
    'Content-Type' => 'text/x-ruby'

  it_behaves_like 'a multipart form file', 2, 'file2', MULTIPART_FILE2,
    'Content-Transfer-Encoding' => 'binary',
    'Content-Type' => 'text/x-ruby'

  it_behaves_like 'a multipart form file', 3, 'file3', MULTIPART_FILE3,
    'Content-Transfer-Encoding' => 'binary',
    'Content-Type' => 'text/x-ruby'
end

shared_examples 'a multipart form value' do |idx, key, value, headers|
  idx = 0 unless idx.to_i > 0
  headers ||= {}

  let(:this_part) { form_parts[idx] }

  it 'with form name' do
    expect(this_part['FormName']).to eq(key.to_s)
  end

  it 'with file name' do
    expect(this_part['FileName']).to eq('')
  end

  it 'with part content' do
    expect(this_part['BodySignature']).to eq(Digest::SHA256.hexdigest(value))
  end

  it 'with part size' do
    expect(this_part['Size']).to eq(value.size)
  end
end

shared_examples 'a multipart form file' do |idx, key, filename, headers|
  idx = 0 unless idx.to_i > 0
  headers ||= {}
  let(:this_part) { form_parts[idx] }

  it 'with form name' do
    expect(this_part['FormName']).to eq(key)
  end

  it 'with file name' do
    expect(this_part['FileName']).to eq(File.basename(filename))
  end

  it 'with part content' do
    expect(this_part['BodySignature']).to eq(Digest::SHA256.file(filename).to_s)
  end

  it 'with part size' do
    expect(this_part['Size']).to eq(File.size(filename))
  end

  headers.each do |key, value|
    it "with #{key} header" do
      expect(this_part['Header'][key]).to eq(value)
    end
  end
end
