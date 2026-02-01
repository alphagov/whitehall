class TopicalEvent
  class SocialMediaLink
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :social_media_service_id, :string
    attribute :url, :string
    attribute :title, :string
    attribute :id
    attribute :_destroy, :boolean

    validates :social_media_service_id, presence: true
    validates :url, presence: true, uri: { allow_blank: true }

    def persisted?
      # Forces Rails form_for to use PATCH (update) instead of POST (create)
      true
    end

    def marked_for_destruction?
      _destroy
    end

    def service_name
      # Look up the service name from the configuration options
      option = self.class.service_options.find { |(_label, value)| value == social_media_service_id }
      return option.first if option

      # Fallback to DB lookup
      SocialMediaService.find_by(id: social_media_service_id)&.name || social_media_service_id.to_s.humanize
    end

    def display_name
      title.presence || service_name
    end

    def self.service_options
      @service_options ||= begin
        definition = ConfigurableDocumentType.find("topical_event")
        definition.forms.dig("documents", "fields", "social_media_service_id", "options") || []
      rescue StandardError
        []
      end
    end
  end
end
