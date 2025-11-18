# config/initializers/carrierwave_patch.rb
#
# This patch fixes a deprecation warning in carrierwave 3.1.2
# "warning: URI::RFC3986_PARSER.escape is obsolete. Use URI::RFC2396_PARSER.escape explicitly."
#
# This patches the private methods inside:
# /.../carrierwave-3.1.2/lib/carrierwave/utilities/uri.rb
# https://github.com/carrierwaveuploader/carrierwave/issues/2796

require "carrierwave/utilities/uri"

module CarrierWave
  module Utilities
    module Uri
      # Re-define the private methods using the correct parser

    private

      def encode_path(path)
        ::URI::RFC2396_PARSER.escape(path, PATH_UNSAFE)
      end

      def encode_non_ascii(str)
        ::URI::RFC2396_PARSER.escape(str, NON_ASCII)
      end

      def decode_uri(str)
        ::URI::RFC2396_PARSER.unescape(str)
      end
    end
  end
end
