# frozen_string_literal: true

module ImageVersions
  module DefaultImageVersions
    extend ActiveSupport::Concern

    included do
      use_default_versions_proc = -> (uploader, opts) do
        uploader.use_default_versions?(**opts)
      end

      version :s960, if: use_default_versions_proc do
        process resize_to_fill: [960, 640]
      end
      version :s712, from_version: :s960, if: use_default_versions_proc do
        process resize_to_fill: [712, 480]
      end
      version :s630, from_version: :s960, if: use_default_versions_proc do
        process resize_to_fill: [630, 420]
      end
      version :s465, from_version: :s960, if: use_default_versions_proc do
        process resize_to_fill: [465, 310]
      end
      version :s300, from_version: :s960, if: use_default_versions_proc do
        process resize_to_fill: [300, 195]
      end
      version :s216, from_version: :s960, if: use_default_versions_proc do
        process resize_to_fill: [216, 140]
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
