require "test_helper"

class CsvFileFromPublicHostTest < ActiveSupport::TestCase
  def encoding_fixture(encoding)
    File.open(Rails.root.join("test/fixtures/csv_encodings/#{encoding}.csv"))
  end

  def stub_csv_request(status: 206, body: '')
    stub_request(:get, "#{Whitehall.public_root}/some-path")
      .with(headers: { 'Range' => 'bytes=0-300000' })
      .to_return(status: status, body: body)
  end

  test '#new yields a temporary file' do
    stub_csv_request

    CsvFileFromPublicHost.new('some-path') do |file|
      assert File.exist?(file.path)
    end
  end

  test '#new handles utf-8 encoding' do
    stub_csv_request(body: encoding_fixture('utf-8'))

    CsvFileFromPublicHost.new('some-path') do |file|
      assert File.exist?(file.path)
    end
  end

  test '#new handles iso-8859-1 encoded files' do
    stub_csv_request(body: encoding_fixture('iso-8859-1'))

    CsvFileFromPublicHost.new('some-path') do |file|
      assert File.exist?(file.path)
    end
  end

  test '#new handles windows-1252 encoded files' do
    stub_csv_request(body: encoding_fixture('windows-1252'))

    CsvFileFromPublicHost.new('some-path') do |file|
      assert File.exist?(file.path)
    end
  end

  test '#new yields a temporary file that contains the contents of the request body' do
    stub_csv_request(body: 'csv,file')

    CsvFileFromPublicHost.new('some-path') do |file|
      assert_equal 'csv,file', file.read
    end
  end

  test '#new raises an exception if the request status is anything other than 206' do
    [404, 502, 503].each do |status|
      stub_csv_request(status: status)
      assert_raises(CsvFileFromPublicHost::ConnectionError) { CsvFileFromPublicHost.new('some-path') }
    end
  end

  test 'uses basic authentication if set in the environment' do
    ENV.stubs(:[]).with('BASIC_AUTH_CREDENTIALS').returns('user:password')
    ENV.stubs(:has_key?).with('BASIC_AUTH_CREDENTIALS').returns(true)
    mock_response = mock('response')
    mock_response.stubs(status: 206, body: '')
    mock_connection = mock('connection')
    mock_connection.stubs(get: mock_response)
    Faraday.stubs(:new).returns(mock_connection)

    mock_connection.expects(:basic_auth).at_least_once.with('user', 'password')

    CsvFileFromPublicHost.new('some-path') {}
  end
end
