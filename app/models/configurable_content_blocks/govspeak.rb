module ConfigurableContentBlocks
  class Govspeak
    include Presenters::PublishingApi::PayloadHeadingsHelper

    attr_reader :images, :attachments

    def initialize(images = [], attachments = [])
      @images = images
      @attachments = attachments
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
        html: Whitehall::GovspeakRenderer.new.govspeak_to_html(content, images: @images, attachments: @attachments),
        **extract_headings(content),
      }
    end

    def to_partial_path
      "admin/configurable_content_blocks/govspeak"
    end
  end
end
