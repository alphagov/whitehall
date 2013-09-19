require 'net/https'
require 'mime/types'

class Whitehall::Uploader::AttachmentCache
  class RetrievalError < RuntimeError; end

  class << self
    attr_accessor :default_root_directory
  end

  def initialize(root_dir = self.class.default_root_directory, logger = Logger.new($stdout))
    @root_dir = root_dir
    @logger = logger
  end

  def fetch(url, line_number)
    Entry.new(@root_dir, @logger, url, line_number).fetch
  end

  class FileTypeDetector
    def self.detected_file_type(local_path)
      file_type = `file "#{local_path}"`.strip
      if file_type =~ /PDF document/
        :pdf
      elsif file_type =~ /Microsoft Excel/
        :xls
      elsif file_type =~ /Microsoft (Office )?Word/
        :doc
      elsif file_type =~ /Microsoft PowerPoint/
        :ppt
      else
        nil
      end
    end

    IGNORED_CONTENT_TYPES = ['application/octet-stream']
    def self.detected_content_type(response)
      if response['Content-Type'] && !IGNORED_CONTENT_TYPES.include?(response['Content-Type'])
        type = MIME::Types[response['Content-Type']]
        return type.first.extensions.first if type && type.any?
      end
      nil
    end
  end

  private

  class Entry
    attr_accessor :root_dir, :logger, :original_url

    def initialize(root_dir, logger, original_url, line_number)
      @root_dir = root_dir
      @logger = logger
      @original_url = original_url
      @line_number = line_number
    end

    def fetch
      if cached_file
        File.open(cached_file, 'r')
      else
        download(original_url)
      end
    end

    def cache_path
      File.join(root_dir, Digest::MD5.hexdigest(original_url))
    end

    def cached_file
      Dir[cache_path + "/*"][0]
    end

    def download(url)
      response = do_request(url)
      if response.is_a?(Net::HTTPOK)
        local_path = store(url, response)
        File.open(local_path, 'r')
      elsif response.is_a?(Net::HTTPMovedPermanently) || response.is_a?(Net::HTTPMovedTemporarily)
        download(response['Location'])
      else
        raise RetrievalError, "got response status #{response.code}"
      end
    rescue Timeout::Error, Errno::ECONNREFUSED, Errno::ECONNRESET => e
      raise RetrievalError, "due to #{e.class}: '#{e.message}'"
    rescue URI::InvalidURIError => e
      raise RetrievalError, "due to invalid URL - #{e.class}: '#{e.message}'"
    end

    def do_request(url)
      uri = URI.parse(url)
      raise RetrievalError, "url not understood to be HTTP" unless uri.is_a?(URI::HTTP)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.is_a?(URI::HTTPS))
      http.request_get(uri.request_uri)
    end

    def filename(url, response)
      filename_from_content_disposition_header(response) || filename_from_url(url)
    end

    def filename_from_content_disposition_header(response)
      if response['Content-Disposition']
        parts = response['Content-Disposition'].split(/; */)
        parts.each do |part|
          # The spec tells us that the filename part of
          # Content-disposition should be quoted, but certain
          # misconfigured web servers don't do that. In the spirit of
          # being generous in what we accept, quotes are optional.
          if match = part.match(/filename *= *"?([^"]+)"?/)
            return match[1]
          end
        end
      end
      nil
    end

    # Some CMSs use a common endpoint like `/download.php` to serve
    # files - we should ignore these as they're not the actual
    # extension of the file.
    IGNORED_COMMON_WEB_EXTENSIONS = ['.do', '.php', '.aspx', '.asp', '.pl', '.jsp', '.cgi', '.dll']
    def filename_from_url(url)
      filename = File.basename(URI.parse(url).path)
      extension = File.extname(filename)
      if IGNORED_COMMON_WEB_EXTENSIONS.include? extension
        File.basename(filename, extension)
      else
        filename
      end
    end

    def store(url, response)
      FileUtils.mkdir_p(cache_path)
      local_path = File.join(cache_path, filename(url, response))
      @logger.info "Fetching #{url} to #{local_path}", @line_number
      File.open(local_path, 'w', encoding: 'ASCII-8BIT') do |file|
        file.write(response.body)
      end
      ensure_file_has_extension(local_path, response)
    end

    def ensure_file_has_extension(local_path, response)
      extension = File.extname(local_path)
      if invalid_extension?(extension)
        detected_type = extension_from_content_type(response) || extension_from_file(local_path)
        if detected_type
          FileUtils.mv(local_path, local_path + ".#{detected_type}")
          local_path = local_path + ".#{detected_type}"
          @logger.info "Detected file type: #{detected_type}; moved to #{local_path}", @line_number
        else
          @logger.warn "Unknown file type for #{local_path}", @line_number
        end
      end
      local_path
    end

    def invalid_extension?(extension)
      # when comparing, remove the trailing . that might be present
      # from File.extname.  EXTENSION_WHITE_LIST doesn't include them
      extension.blank? ||
      !AttachmentUploader::EXTENSION_WHITE_LIST.include?(extension.downcase.gsub(/^\./,''))
    end

    def extension_from_file(local_path)
      FileTypeDetector.detected_file_type(local_path)
    end

    def extension_from_content_type(response)
      FileTypeDetector.detected_content_type(response)
    end

  end
end
