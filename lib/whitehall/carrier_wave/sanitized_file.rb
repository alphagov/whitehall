module CarrierWave
  class SanitizedFile
    # CarrierWave has been designed with the assumption that your files will
    # be uploaded to and served from the same directory. We've added a virus
    # checking step, and so have two folders involved ("incoming" and "clean").
    #
    # By default, CarrierWave will generate the URL of an asset by taking its
    # path relative to the folder it was uploaded to (e.g. /public) and append
    # it to `asset_host`.
    #
    # We've changed this behaviour by defining this `url` method, which returns
    # a consistent value regardless of whether or not an uploaded file has been
    # checked for viruses, as the view code (that calls it) needs to return the
    # same URL in both cases.
    def url
      CarrierWaveFilePath.new(path).to_public_path
    end

    class CarrierWaveFilePath
      def initialize(path)
        @path = path
      end

      def to_public_path
        parent_folder = path_in_clean_folder? ? Whitehall.clean_uploads_root : Whitehall.incoming_uploads_root
        routing_prefix + strip_parent_folder(@path, parent_folder)
      end

      private

      def path_in_clean_folder?
        @path.starts_with?(Whitehall.clean_uploads_root)
      end

      def strip_parent_folder(path, parent)
        path.sub(/^#{parent}/, '').to_s
      end

      def routing_prefix
        "/government/uploads"
      end
    end
  end
end
