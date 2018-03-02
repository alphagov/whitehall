class CsvFileFromPublicHost
  class ConnectionError < StandardError; end

  MAXIMUM_RANGE_BYTES = '30000'.freeze

  def initialize(path)
    @path = path

    Tempfile.create(temp_fn, temp_dir) do |tmp_file|
      tmp_file.write(csv_file)
      tmp_file.rewind
      yield(tmp_file)
    end
  end

private

  def connection
    conn = Faraday.new(url: Whitehall.public_root)
    conn.basic_auth(basic_auth_user, basic_auth_password) if ENV.has_key?("BASIC_AUTH_CREDENTIALS")
    conn
  end

  def response
    connection.get(@path) do |req|
      req.headers['Range'] = "bytes=0-#{MAXIMUM_RANGE_BYTES}"
    end
  end

  def csv_file
    raise ConnectionError unless response.status == 206
    response.body
  end

  def temp_dir
    File.join(Rails.root, 'tmp')
  end

  def temp_fn
    CGI.escape(@path)
  end

  def basic_auth_user
    basic_auth_credentials[0]
  end

  def basic_auth_password
    basic_auth_credentials[1]
  end

  def basic_auth_credentials
    ENV["BASIC_AUTH_CREDENTIALS"].split(":")
  end
end
