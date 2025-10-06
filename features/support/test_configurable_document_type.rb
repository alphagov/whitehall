module ConfigurableDocumentTypes
  class TestConfigurableDocumentTypeProperties < BaseProperties
    block_attribute :body do
      default=""
      block=ConfigurableContentBlocks::Govspeak
    end
    block_attribute :image do
      block=ConfigurableContentBlocks::ImageSelect
    end
    validates :body, presence: true
  end

  class TestConfigurableDocumentType < StandardEdition
    include Edition::Images
    include Edition::Translatable
    validates_associated :block_content

    include_association ConfigurableAssociations::Organisations
    set_configuration(
      "test",
      "Test"
    )

    def translatable?
      true
    end

    class TestConfigurableDocumentTypeConfig
      class << self

        def key
          "test"
        end

        def title
          "Test configurable document type"
        end

        def description
          "A test type"
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

    def self.properties
      TestConfigurableDocumentTypeProperties
    end
  end
end
