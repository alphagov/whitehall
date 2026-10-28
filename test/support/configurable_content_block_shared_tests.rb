module ConfigurableContentBlockSharedTests
  extend ActiveSupport::Concern

  def test_it_does_not_render_if_the_edition_is_a_translation_and_the_field_is_not_translatable
    @field["translatable"] = false
    with_locale(:es) do
      html = render block
      assert_empty html
    end
    @field["translatable"] = true
  end

  def test_it_does_not_render_if_the_configurable_document_types_feature_flag_is_disabled_and_the_field_is_experimental
    @field["experimental"] = true
    html = render block
    assert_empty html
    @field["experimental"] = false
  end

  included do
    test "it does inherit from parent, if `inherit_from_parent` set and it is an empty field of a new edition" do
      parent_edition = setup_and_create_parent_edition

      @edition = StandardEdition.new(
        configurable_document_type: @configurable_document_type,
        document: create(:document),
        parent_edition_id: parent_edition.id,
      )

      render block

      # the edition is new and so we want the fields to inherit the parent values
      assert_nil @edition.block_content

      field_with_value.each do |selector|
        assert_select(*selector)
      end
    end

    test "it does not inherit from parent, if `inherit_from_parent` set and it is an empty field of a saved edition" do
      @configurable_document_type ||= "test_type"

      ConfigurableDocumentType.setup_test_types(build_configurable_document_type(
        @configurable_document_type,
        ConfigurableDocumentType.types["#{@configurable_document_type}"].deep_merge({
          "settings" => {
            "allowed_child_document_types" => [
              {
                "document_type" => @configurable_document_type,
              },
            ],
          }
        })
      ))

      parent_edition = setup_and_create_parent_edition

      @edition = create(
        :draft_standard_edition,
        configurable_document_type: @configurable_document_type,
        parent_edition_id: parent_edition.id,
      )

      render block

      # as the edition is saved, we don't want the fields to inherit the parent
      # values as the user has decided those fields should be intentionally empty
      field_with_value.each do |selector|
        refute_select(*selector)
      end
    end

    def setup_and_create_parent_edition
      @field["required"] = false # otherwise can't test an empty field inherits from parent
      @field["inherit_from_parent"] = true

      if @field["fields"].present?
        @field["fields"].each do |_, field|
          field["inherit_from_parent"] = true
        end
      end

      @configurable_document_type ||= "test_type"

      parent_edition = create(:draft_standard_edition, configurable_document_type: @configurable_document_type)
      fill_in_field(parent_edition)
      parent_edition.save!

      parent_edition
    end

    def field_with_value
      [
        "[name=\"edition[block_content][test_attribute]\"][value=\"#{@content}\"]",
      ]
    end
  end
end
