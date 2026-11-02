module ConfigurableContentBlockSharedTests
  extend ActiveSupport::Concern

  def test_it_does_not_render_if_the_edition_is_a_translation_and_the_field_is_not_translatable
    @field["translatable"] = false
    with_locale(:es) do
      html = render @block
      assert_empty html
    end
    @field["translatable"] = true
  end

  def test_it_does_not_render_if_the_configurable_document_types_feature_flag_is_disabled_and_the_field_is_experimental
    @field["experimental"] = true
    html = render @block
    assert_empty html
    @field["experimental"] = false
  end

  def it_correctly_inherits_from_parent(block_type, field, path, selectors, fill_in_field, configurable_document_type = nil)
    configurable_document_type ||= "test_type"

    edition = StandardEdition.new(
      configurable_document_type:,
      document: create(:document),
      parent_edition_id: setup_and_create_parent_edition(field, fill_in_field, configurable_document_type).id,
    )

    render block_type.new(edition, field, path)

    # the edition is new and so we want the fields to inherit the parent values
    assert_nil edition.block_content

    selectors.each do |selector|
      assert_select(*selector)
    end
  end

  def it_does_not_inherit_from_parent(block_type, field, path, selectors, fill_in_field, configurable_document_type = nil)
    configurable_document_type ||= "test_type"

    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(
                                                configurable_document_type,
                                                ConfigurableDocumentType.types[configurable_document_type.to_s].deep_merge({
                                                  "settings" => {
                                                    "allowed_child_document_types" => [
                                                      {
                                                        "document_type" => configurable_document_type,
                                                      },
                                                    ],
                                                  },
                                                }),
                                              ))
    edition = create(
      :draft_standard_edition,
      configurable_document_type:,
      parent_edition_id: setup_and_create_parent_edition(field, fill_in_field, configurable_document_type).id,
    )

    render block_type.new(edition, field, path)

    selectors.each do |selector|
      refute_select(*selector)
    end
  end

  def setup_and_create_parent_edition(field, fill_in_field, configurable_document_type = nil)
    configurable_document_type ||= "test_type"

    field["required"] = false # otherwise can't test an empty field inherits from parent
    field["inherit_from_parent"] = true

    if field["fields"].present?
      field["fields"].each do |_, field|
        field["inherit_from_parent"] = true
      end
    end

    parent_edition = create(:draft_standard_edition, configurable_document_type:)
    fill_in_field.call(parent_edition)
    parent_edition.save!

    parent_edition
  end
end
