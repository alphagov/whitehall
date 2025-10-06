module ConfigurableDocumentTypes
  class HistoryPageProperties < BaseProperties
    block_attribute :body, :string, default: "", block: ConfigurableContentBlocks::Govspeak
    block_attribute :lead_paragraph, :string, block: ConfigurableContentBlocks::DefaultString
    block_attribute :sidebar_image, :integer, block: ConfigurableContentBlocks::ImageSelect
    self.attributes_with_headings = [:body]
    validates :body, presence: true
  end

  class HistoryPage < StandardEdition
    include Edition::Images
    validates_associated :block_content

    include_association ConfigurableAssociations::Organisations

    class HistoryPageConfig
      class << self
        def key
          "history_page"
        end

        def title
          "History page"
        end

        def description
          "A history page on GOV.UK"
        end

        def attribute_label(attribute_name)
          {
            "body" => "Body",
            "image" => "Image",
          }[attribute_name]
        end

        def attribute_hint_text(attribute_name)
          {
            "body" => "The main content for the page",
            "image" => "Select an image to display on the page",
          }[attribute_name]
        end

        def base_path_prefix
          "/government/test-type"
        end
        def publishing_api_schema_name
          "test_type"
        end

        def publishing_api_document_type
          "test_type"
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
      HistoryPageConfig
    end

    def self.properties
      HistoryPageProperties
    end
  end
end