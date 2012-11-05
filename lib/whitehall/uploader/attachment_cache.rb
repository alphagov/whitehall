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
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPOK)
        filename = File.basename(uri.path)
        FileUtils.mkdir_p(cache_path(url))
        local_path = File.join(cache_path(url), filename)
        @logger.info "Fetching #{url} to #{local_path}"
        File.open(local_path, 'w', encoding: 'ASCII-8BIT') do |file|
          file.write(response.body)
        end
        if File.extname(local_path) == ""
          file_type = `file -e cdf -b "#{local_path}"`.strip
          if file_type =~ /^PDF /
            FileUtils.mv(local_path, local_path + ".pdf")
            local_path = local_path + ".pdf"
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
