# frozen_string_literal: true

module ImageVersions
  module DefaultImageVersions
    extend ActiveSupport::Concern

    included do
      Whitehall.image_kinds.each do |image_kind, image_kind_config|
        use_versions_for_this_image_kind_proc = lambda do |uploader, opts|
          file = opts[:file]
          uploader.model.image_kind == image_kind && uploader.bitmap?(file)
        end

        image_kind_config.versions.each do |v|
          version v.name, from_version: v.from_version, if: use_versions_for_this_image_kind_proc do
            process resize_to_fill: v.resize_to_fill
          end
        end
      end

      def bitmap?(new_file)
        return if new_file.nil?

        new_file.content_type !~ /svg/
      end
    end
  end
end
