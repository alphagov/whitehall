module ConfigurableDocumentTypes
  class TestConfigurableDocumentTypeProperties < BaseProperties
    block_attribute :body do
      default ""
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

    block_attribute :body do
      label="Body"
      hint_text="The body of the document"
      default=""
      block=:govspeak
    end
    block_attribute :image do
      label="Image"
      hint_text="The image for the document"
      block=:image_select
    end
    block_content_validation do
      validates :body, presence: true
    end
    associations(ConfigurableAssociations::Organisations)
    settings(
      key: "test",
      label: "Test",
      description: "",
      base_path_prefix: "",
      publishing_api_schema_name: "",
      publishing_api_document_type: "",
      rendering_app: "",
      authorised_organisations: "",
    )
  end
end
