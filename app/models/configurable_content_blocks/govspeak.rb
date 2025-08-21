module ConfigurableContentBlocks
  class Govspeak
    include Presenters::PublishingApi::PayloadHeadingsHelper

    def initialize(images = [])
      @images = images
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
        html: Whitehall::GovspeakRenderer.new.govspeak_to_html_with_images_and_attachments(content, @images),
        **extract_headings(content),
      }
    end

    def to_partial_path
      "admin/configurable_content_blocks/govspeak"
    end
  end
end
