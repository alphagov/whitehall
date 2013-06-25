# TODO: Explain this monkey-patch
module CarrierWave
  class SanitizedFile
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
