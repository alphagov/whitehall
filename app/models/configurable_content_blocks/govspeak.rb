module ConfigurableContentBlocks
  class Govspeak
    include Presenters::PublishingApi::PayloadHeadingsHelper
    include GovspeakHelper

    attr_reader :images, :attachments, :path, :type_config, :type_properties, :content, :translated_content, :right_to_left

    def initialize(edition, path, translated_edition = nil)
      @images = edition.respond_to?(:images) ? edition.images : []
      @attachments = edition.respond_to?(:attachments) ? edition.attachments : []
      @path = path
      @type_config = edition.class.config
      @type_properties = edition.class.properties
      @content = path.to_a.inject(edition.block_content) do |content, segment|
        content.present? ? content.public_send(segment) : nil
      end
      @translated_content = path.to_a.inject(translated_edition.block_content) do |content, segment|
        content.present? ? content.public_send(segment) : nil
      end unless translated_edition.nil?
      @right_to_left = translated_edition&.translation_rtl?
    end

    def json_schema_type
      "string"
    end

    def json_schema_format
      "govspeak"
    end

    def json_schema_validator
      proc do |instance|
        instance.is_a?(String) && ::Govspeak::HtmlValidator.new(instance).valid?
      end
    end

    def publishing_api_payload(content)
      {
        html: govspeak_to_html(content, images: @images, attachments: @attachments),
        **extract_headings(content),
      }
    end

    def to_partial_path
      "admin/configurable_content_blocks/govspeak"
    end
  end
end
