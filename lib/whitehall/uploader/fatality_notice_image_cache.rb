module Whitehall::Uploader
  class FatalityNoticeImageCache
    def initialize(root_dir = self.class.default_root_directory, logger = Logger.new($stdout))
      @root_dir = root_dir
      @logger = logger
    end

    def fetch(url)
      filename = Pathname.new(@root_dir) + (Digest::MD5.hexdigest(url) + ".jpg")
      File.open(filename, 'r:binary')
    rescue Errno::ENOENT
      @logger.error("Couldn't find image for url '#{url}', was looking for file '#{filename}'")
      nil
    end

    def self.default_root_directory
      "/data/uploads/whitehall/fatality_notices"
    end
  end
end