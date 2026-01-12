module ConfigurableContentBlocks
  class Govspeak
    include Presenters::PublishingApi::PayloadHeadingsHelper
    include GovspeakHelper

    attr_reader :images, :attachments

    def initialize(images = [], attachments = [])
      @images = images
      @attachments = attachments
    end

    def to_partial_path
      "admin/configurable_content_blocks/govspeak"
    end
  end
end
