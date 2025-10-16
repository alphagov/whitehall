module ConfigurableContentBlocks
  class Govspeak
    include Presenters::PublishingApi::PayloadHeadingsHelper
    include GovspeakHelper

    attr_reader :images, :attachments

    def initialize(images = [], attachments = [])
      @images = images
      @attachments = attachments
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
