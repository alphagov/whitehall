require "test_helper"

class CsvFileFromPublicHostTest < ActiveSupport::TestCase
  def stub_csv_request(status: 206, body: '')
    stub_request(:get, "#{Whitehall.public_root}/some-path")
      .with(headers: { 'Range' => 'bytes=0-30000' })
      .to_return(status: status, body: body)
  end

  test '#new yields a temporary file' do
    stub_csv_request

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
end
