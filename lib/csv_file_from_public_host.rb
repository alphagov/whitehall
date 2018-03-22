class CsvFileFromPublicHost
  class ConnectionError < StandardError; end
  class FileEncodingError < ::EncodingError
  end

  MAXIMUM_RANGE_BYTES = '300000'.freeze

  def self.csv_preview(path)
    csv_preview = nil
    new(path) do |file|
      csv_preview = CsvPreview.new(file.path)
    end
    csv_preview
  rescue CsvPreview::FileEncodingError, CSV::MalformedCSVError, CsvFileFromPublicHost::ConnectionError, CsvFileFromPublicHost::FileEncodingError
    nil
  end

  def initialize(path)
    @path = path

    response = connection.get(@path) do |req|
      req.headers['Range'] = "bytes=0-#{MAXIMUM_RANGE_BYTES}"
    end

    csv_file = begin
      raise ConnectionError unless response.status == 206
      body = response.body
      set_encoding!(body)
      body
    end

    temp_fn = CGI.escape(@path).truncate(50)
    temp_dir = File.join(Rails.root, 'tmp')

    Tempfile.create(temp_fn, temp_dir, encoding: csv_file.encoding) do |tmp_file|
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

  def basic_auth_user
    basic_auth_credentials[0]
  end

  def basic_auth_password
    basic_auth_credentials[1]
  end

  def basic_auth_credentials
    ENV["BASIC_AUTH_CREDENTIALS"].split(":")
  end

  def set_encoding!(body)
    if utf_8_encoding?(body)
      body.force_encoding('utf-8')
    elsif windows_1252_encoding?(body)
      body.force_encoding('windows-1252')
    else
      raise FileEncodingError, 'File encoding not recognised'
    end
  end

  def utf_8_encoding?(body)
    body.force_encoding('utf-8').valid_encoding?
  end

  def windows_1252_encoding?(body)
    body.force_encoding('windows-1252')
    # This regexp checks for the presence of ASCII control characters, which
    # would indicate we have the wrong encoding.
    body.valid_encoding? && !body.match(/[\x00-\x08\x0b\x0c\x0e-\x1f]/)
  end
end
