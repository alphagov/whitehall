module ConfigurableDocumentTypes
  class NewsStoryProperties
    include StoreModel::Model

    attribute :body, :string, default: ""
    attribute :lead_image, :integer, default: nil
    validates :body, presence: true
  end

  class NewsStory < StandardEdition
    include Edition::Images
    include ::Attachable
    include Edition::RoleAppointments
    include Edition::TopicalEvents
    include Edition::WorldLocations
    include Edition::Organisations
    include Edition::Images
    include ::Attachable
    include Edition::AlternativeFormatProvider
    include Edition::Translatable

    attribute :block_content, NewsStoryProperties.to_type
    validates :block_content, store_model: { merge_errors: true }

    class NewsStoryConfig
      class << self
        def key
          "news_story"
        end

        def title
          "News Story"
        end

        def description
          "News written exclusively for GOV.UK which users need, can act on and can’t get from other sources. Avoid duplicating press releases."
        end

        def attribute_label(attribute_name)
          {
            :body => "Body",
            :lead_image => "Lead Image",
          }[attribute_name]
        end

        def attribute_hint_text(attribute_name)
          {
            :body => "The main content for the page",
            :lead_image => "Select an image to display at the top of the story",
          }[attribute_name]
        end

        def base_path_prefix
          "/government/news"
        end
        def publishing_api_schema_name
          "news_article"
        end

        def publishing_api_document_type
          "news_story"
        end

        def rendering_app
          "frontend"
        end

        def authorised_organisations
          nil
        end
      end
    end

    def self.config
      NewsStoryConfig
    end
  end
end
