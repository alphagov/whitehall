class TopicalEvent
  module SocialMediaMigration
    # This concern supports reading/writing social media accounts from the new 'block_content'
    # JSON column while maintaining compatibility with existing data and the legacy frontend
    extend ActiveSupport::Concern

    included do
      before_validation :sync_block_content_body
    end

    def reload(*)
      @social_media_accounts = nil
      super
    end

    def sync_block_content_body
      # The new schema requires 'body' (govspeak), which maps to the legacy 'description'.
      # We sync them here to satisfy BlockContent validation without changing the legacy form yet.
      if block_content && description.present?
        self.block_content = block_content.to_h.merge("body" => description)
      end
    end

    # Intercept form submission to save to block_content
    def social_media_accounts_attributes=(attributes)
      return unless attributes.is_a?(Hash)

      self.block_content = (block_content || {}).to_h.merge("social_media_links" => attributes)
      @social_media_accounts = nil
    end

    def social_media_accounts
      @social_media_accounts ||= if (content = block_content) && content.respond_to?(:social_media_links) && content.social_media_links.present?
                                   (content.social_media_links || []).map do |link_data|
                                     link = TopicalEvent::SocialMediaLink.new(link_data)
                                     link.valid?
                                     link
                                   end
                                 else
                                   super
                                 end
    end

    def block_content
      content = super || StandardEdition::BlockContent.new(type_instance.schema)

      return content unless should_fallback_to_legacy?(content)

      merge_legacy_accounts_into(content)
      content
    end

  private

    def should_fallback_to_legacy?(content)
      return false unless content.respond_to?(:social_media_links)

      content.social_media_links.blank?
    end

    def merge_legacy_accounts_into(content)
      legacy_accounts = association(:social_media_accounts).reader.select { |a| a.social_media_service.present? }

      return unless legacy_accounts.any?

      content.social_media_links = legacy_accounts.map do |account|
        {
          "social_media_service_id" => account.social_media_service.name.downcase.parameterize,
          "url" => account.url,
          "title" => account.title,
        }
      end
    end
  end
end
