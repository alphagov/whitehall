module ConfigurableDocumentTypes
  class TestConfigurableDocumentTypeProperties
    include ActiveModel::Attributes
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations
    @attribute_blocks = {}
    @attributes_with_headings = []

    class << self
      attr_accessor :attributes_with_headings
      def block_attribute(name, cast_type = nil, default: nil, **options)
        @attribute_blocks[name] = options.delete(:block)
        attribute(name, cast_type, default:, **options)
      end

      def block_for_attribute(attribute_name)
        @attribute_blocks[attribute_name.to_sym]
      end

      def attribute_required?(attribute_name)
        self.validators_on(attribute_name).map(&:class).include?(ActiveModel::Validations::PresenceValidator)
      end
    end

    block_attribute :body, :string, default: "", block: ConfigurableContentBlocks::Govspeak
    block_attribute :image, :integer, block: ConfigurableContentBlocks::ImageSelect
    self.attributes_with_headings = [:body]
    validates :body, presence: true
  end

  class TestConfigurableDocumentType < StandardEdition
    include Edition::Images
    include Edition::Translatable
    validates_associated :block_content

    include_association ConfigurableAssociations::Organisations

    def translatable?
      true
    end

    def block_content=(value)
      if value.is_a? TestConfigurableDocumentTypeProperties
        super(value.attributes)
      else
        super(value)
      end
    end

    def block_content
      return nil if self[:block_content].nil?

      TestConfigurableDocumentTypeProperties.new.tap do |properties|
        properties.assign_attributes(self[:block_content])
      end
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

    def self.config
      TestConfigurableDocumentTypeConfig
    end

    def self.properties
      TestConfigurableDocumentTypeProperties
    end
  end
end
