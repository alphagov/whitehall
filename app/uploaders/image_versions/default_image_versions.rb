# frozen_string_literal: true

module ImageVersions
  module DefaultImageVersions
    extend ActiveSupport::Concern

    VERSIONS = {
      s960: {
        width: 960,
        height: 640,
      },
      s712: {
        width: 712,
        height: 480,
        from_version: :s960,
      },
      s630: {
        width: 630,
        height: 420,
        from_version: :s960,
      },
      s465: {
        width: 465,
        height: 310,
        from_version: :s960,
      },
      s300: {
        width: 300,
        height: 195,
        from_version: :s960,
      },
      s216: {
        width: 216,
        height: 140,
        from_version: :s960,
      },
    }

    included do
      use_default_versions_proc = -> (uploader, opts) do
        uploader.use_default_versions?(version: opts[:version], file: opts[:file])
      end

      VERSIONS.each do |name, opts|
        version name, from_version: opts[:from_version], if: use_default_versions_proc do
          process resize_to_fill: opts.values_at(:width, :height)
        end
      end

      def use_default_versions?(version:, file:)
        result = bitmap?(file)
        warn("use_default_versions?(#{version}, #{file}) -> #{result}")
        result
      end

      def bitmap?(new_file)
        return if new_file.nil?

        new_file.content_type !~ /svg/
      end
    end
  end
end
