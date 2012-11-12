require 'net/https'

class Whitehall::Uploader::AttachmentCache
  class RetrievalError < RuntimeError; end

  class << self
    attr_accessor :default_root_directory
  end

  def initialize(root_dir = self.class.default_root_directory, logger = Logger.new($stdout))
    @root_dir = root_dir
    @logger = logger
  end

  def fetch(url)
    if cached_file(url)
      File.open(cached_file(url), 'r')
    else
      download(url)
    end
  end

  class FileTypeDetector
    def self.detected_type(local_path)
      file_type = `file "#{local_path}"`.strip
      if file_type =~ /PDF document/
        :pdf
      elsif file_type =~ /Microsoft Excel/
        :xls
      elsif file_type =~ /Microsoft Office Word/
        :doc
      else
        nil
      end
    end
  end


  private

  def cache_path(url)
    File.join(@root_dir, Digest::MD5.hexdigest(url))
  end

  def cached_file(url)
    Dir[cache_path(url) + "/*"][0]
  end

  def download(url)
    uri = URI.parse(url)
    if uri.is_a?(URI::HTTP)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.is_a?(URI::HTTPS))
      response = http.request_get(uri.path)
      if response.is_a?(Net::HTTPOK)
        filename = File.basename(uri.path)
        FileUtils.mkdir_p(cache_path(url))
        local_path = File.join(cache_path(url), filename)
        @logger.info "Fetching #{url} to #{local_path}"
        File.open(local_path, 'w', encoding: 'ASCII-8BIT') do |file|
          file.write(response.body)
        end
        if File.extname(local_path).blank?
          detected_type = FileTypeDetector.detected_type(local_path)
          if detected_type
            FileUtils.mv(local_path, local_path + ".#{detected_type}")
            local_path = local_path + ".#{detected_type}"
            @logger.info "Detected file type: #{detected_type}; moved to #{local_path}"
          else
            @logger.warn "Unknown file type for #{local_path}"
          end
        end
        File.open(local_path, 'r')
      elsif response.is_a?(Net::HTTPMovedPermanently)
        download(response['Location'])
      else
        raise RetrievalError, "got response status #{response.code}"
      end
    else
      raise RetrievalError, "url not understood to be HTTP"
    end
  rescue Timeout::Error, Errno::ECONNREFUSED, Errno::ECONNRESET => e
    raise RetrievalError, "due to #{e.class}: '#{e.message}'"
  rescue URI::InvalidURIError => e
    raise RetrievalError, "due to invalid URL - #{e.class}: '#{e.message}'"
  end
end
