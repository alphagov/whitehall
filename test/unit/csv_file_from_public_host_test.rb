require "test_helper"

class CsvFileFromPublicHostTest < ActiveSupport::TestCase
  def encoding_fixture(encoding)
    File.open(Rails.root.join("test/fixtures/csv_encodings/#{encoding}.csv"))
  end

  def stub_csv_request(status: 206, body: '', path: 'some-path')
    stub_request(:get, "#{Whitehall.public_root}/#{path}")
      .with(headers: { 'Range' => 'bytes=0-300000' })
      .to_return(status: status, body: body)
  end

  test '.new yields a temporary file' do
    stub_csv_request

    response = CsvFileFromPublicHost.csv_response('some-path')
    CsvFileFromPublicHost.new(response) do |file|
      assert File.exist?(file.path)
    end
  end

  test '.new handles utf-8 encoding' do
    stub_csv_request(body: encoding_fixture('utf-8'))

    response = CsvFileFromPublicHost.csv_response('some-path')
    CsvFileFromPublicHost.new(response) do |file|
      assert File.exist?(file.path)
    end
  end

  test '.new handles iso-8859-1 encoded files' do
    stub_csv_request(body: encoding_fixture('iso-8859-1'))

    response = CsvFileFromPublicHost.csv_response('some-path')
    CsvFileFromPublicHost.new(response) do |file|
      assert File.exist?(file.path)
    end
  end

  test '.new handles windows-1252 encoded files' do
    stub_csv_request(body: encoding_fixture('windows-1252'))

    response = CsvFileFromPublicHost.csv_response('some-path')
    CsvFileFromPublicHost.new(response) do |file|
      assert File.exist?(file.path)
    end
  end

  test '.new yields a temporary file that contains the contents of the response body' do
    stub_csv_request(body: 'csv,file')

    response = CsvFileFromPublicHost.csv_response('some-path')
    CsvFileFromPublicHost.new(response) do |file|
      assert_equal 'csv,file', file.read
    end
  end

  test '.new raises an exception if the response status is anything other than 206' do
    [404, 502, 503].each do |status|
      stub_csv_request(status: status)
      assert_raises(CsvFileFromPublicHost::ConnectionError) do
        response = CsvFileFromPublicHost.csv_response('some-path')
        CsvFileFromPublicHost.new(response)
      end
    end
  end

  test '.csv_preview_from builds and returns a CsvPreview using response body' do
    response = stub('response')
    file = stub('file', path: 'some-path')
    CsvFileFromPublicHost.stubs(:new).with(response).yields(file)
    csv_preview = stub('csv-preview')
    CsvPreview.stubs(:new).with('some-path').returns(csv_preview)

    assert_equal csv_preview, CsvFileFromPublicHost.csv_preview_from(response)
  end

  test '.csv_preview_from returns nil if CsvPreview::FileEncodingError is raised' do
    response = stub('response')
    file = stub('file', path: 'some-path')
    CsvFileFromPublicHost.stubs(:new).with(response).yields(file)
    CsvPreview.stubs(:new).with('some-path').raises(CsvPreview::FileEncodingError)

    assert_nil CsvFileFromPublicHost.csv_preview_from(response)
  end

  test '.csv_preview_from returns nil if CSV::MalformedCSVError is raised' do
    response = stub('response')
    file = stub('file', path: 'some-path')
    CsvFileFromPublicHost.stubs(:new).with(response).yields(file)
    CsvPreview.stubs(:new).with('some-path').raises(CSV::MalformedCSVError)

    assert_nil CsvFileFromPublicHost.csv_preview_from(response)
  end

  test '.csv_preview_from returns nil if CsvFileFromPublicHost::ConnectionError is raised' do
    response = stub('response')
    CsvFileFromPublicHost.stubs(:new).with(response)
      .raises(CsvFileFromPublicHost::ConnectionError)
    csv_preview = stub('csv-preview')
    CsvPreview.stubs(:new).with('some-path').returns(csv_preview)

    assert_nil CsvFileFromPublicHost.csv_preview_from(response)
  end

  test '.csv_preview_from returns nil if CsvFileFromPublicHost::FileEncodingError is raised' do
    response = stub('response')
    CsvFileFromPublicHost.stubs(:new).with(response)
      .raises(CsvFileFromPublicHost::FileEncodingError)
    csv_preview = stub('csv-preview')
    CsvPreview.stubs(:new).with('some-path').returns(csv_preview)

    assert_nil CsvFileFromPublicHost.csv_preview_from(response)
  end

  test '#csv_response uses basic authentication if set in the environment' do
    stub_csv_request.with(basic_auth: %w(user password))
    env = { 'BASIC_AUTH_CREDENTIALS' => 'user:password' }

    response = CsvFileFromPublicHost.csv_response('some-path', env: env)
    assert_equal 206, response.status
  end
end
