module ConfigurableDocumentTypes
  class HistoryPageProperties
    include StoreModel::Model

    attribute :body, :string
    attribute :sidebar_image, :integer
    attribute :lead_paragraph, :string
    validates :body, presence: true
    validates_with NoFootnotesInGovspeakValidator, attribute: :body
    validates_with InternalPathLinksValidator, on: :publish
    validates_with GovspeakContactEmbedValidator, on: :publish
  end

  class HistoryPage < StandardEdition
    include Edition::Images

    attribute :block_content, HistoryPageProperties.to_type
    validates :block_content, store_model: { merge_errors: true }

    class HistoryPageConfig
      class << self
        def key
          "history_page"
        end

        def title
          "History Page"
        end

        def description
          "A history page on GOV.UK"
        end

        def attribute_label(attribute_name)
          {
            :body => "Body",
            :sidebar_image => "Sidebar Image",
            :lead_paragraph => "Lead Paragraph"
          }[attribute_name]
        end

        def attribute_hint_text(attribute_name)
          {
            :body => "The main content for the page",
            :sidebar_image => "Select an image to display in the page sidebar",
            :lead_paragraph => "Optional text that appears above the main content"
          }[attribute_name]
        end

        def base_path_prefix
          "/government/history"
        end
        def publishing_api_schema_name
          "history"
        end

        def publishing_api_document_type
          "history"
        end

        def rendering_app
          "frontend"
        end

        def authorised_organisations
          ["af07d5a5-df63-4ddc-9383-6a666845ebe9"]
        end
      end
    end

    def self.config
      HistoryPageConfig
    end
  end
end
