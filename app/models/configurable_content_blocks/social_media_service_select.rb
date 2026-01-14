module ConfigurableContentBlocks
  class SocialMediaServiceSelect
    attr_reader :services

    def initialize
      @services = SocialMediaService.all
    end

    def to_partial_path
      "admin/configurable_content_blocks/social_media_service_select"
    end
  end
end
