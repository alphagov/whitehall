require "test_helper"

class ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  let(:details) do
    {
      "embedded-objects" => {
        "my-embedded-object" => {
          "name" => "My Embedded Object",
          "field-1" => "Value 1",
          "field-2" => "Value 2",
        },
      },
    }
  end

  let(:schema) { stub(:schema) }
  let(:subschema) { stub(:subschema, embeddable_fields: %w[name field-1 field-2]) }
  let(:document) { build(:content_block_document, :email_address, schema:) }
  let(:content_block_edition) { build_stubbed(:content_block_edition, :email_address, details:, document:) }

  before do
    schema.stubs(:subschema).returns(subschema)
  end

  it "renders a summary list" do
    component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
      content_block_edition:,
      object_type: "embedded-objects",
      object_name: "my-embedded-object",
    )

    render_inline component

    assert_selector ".govuk-summary-card__title", text: "Embedded Object details"

    assert_selector ".govuk-summary-list__row", text: /Name/ do
      assert_selector ".govuk-summary-list__key", text: "Name"
      assert_selector ".govuk-summary-list__value", text: "My Embedded Object"
    end

    assert_selector ".govuk-summary-list__row", text: /Field 1/ do
      assert_selector ".govuk-summary-list__key", text: "Field 1"
      assert_selector ".govuk-summary-list__value", text: "Value 1"
    end

    assert_selector ".govuk-summary-list__row", text: /Field 2/ do
      assert_selector ".govuk-summary-list__key", text: "Field 2"
      assert_selector ".govuk-summary-list__value", text: "Value 2"
    end
  end

  it "renders copy code buttons" do
    component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
      content_block_edition:,
      object_type: "embedded-objects",
      object_name: "my-embedded-object",
    )

    render_inline component

    assert_selector ".govuk-summary-list__row[data-embed-code='#{content_block_edition.document.embed_code_for_field('embedded-objects/my-embedded-object/name')}']", text: "Name"
    assert_selector ".govuk-summary-list__row[data-embed-code='#{content_block_edition.document.embed_code_for_field('embedded-objects/my-embedded-object/field-1')}']", text: "Field 1"
    assert_selector ".govuk-summary-list__row[data-embed-code='#{content_block_edition.document.embed_code_for_field('embedded-objects/my-embedded-object/field-2')}']", text: "Field 2"
  end

  it "renders an embed code row for each field" do
    component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
      content_block_edition:,
      object_type: "embedded-objects",
      object_name: "my-embedded-object",
    )

    render_inline component

    assert_selector ".govuk-summary-list__row[data-embed-code-row='true']", text: content_block_edition.document.embed_code_for_field("embedded-objects/my-embedded-object/name")
    assert_selector ".govuk-summary-list__row[data-embed-code-row='true']", text: content_block_edition.document.embed_code_for_field("embedded-objects/my-embedded-object/field-1")
    assert_selector ".govuk-summary-list__row[data-embed-code-row='true']", text: content_block_edition.document.embed_code_for_field("embedded-objects/my-embedded-object/field-2")
  end

  describe "when only some fields are embeddable" do
    let(:subschema) { stub(:subschema, embeddable_fields: %w[field-1]) }

    it "only renders copy code buttons for embeddable fields" do
      component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
        content_block_edition:,
        object_type: "embedded-objects",
        object_name: "my-embedded-object",
      )

      render_inline component

      assert_no_selector ".govuk-summary-list__row[data-embed-code='#{content_block_edition.document.embed_code_for_field('embedded-objects/my-embedded-object/name')}']", text: "Name"
      assert_no_selector ".govuk-summary-list__row[data-embed-code='#{content_block_edition.document.embed_code_for_field('embedded-objects/my-embedded-object/field-2')}']", text: "Field 2"

      assert_selector ".govuk-summary-list__row[data-embed-code='#{content_block_edition.document.embed_code_for_field('embedded-objects/my-embedded-object/field-1')}']", text: "Field 1"
    end

    it "only renders an embed code row for embeddable fields" do
      component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
        content_block_edition:,
        object_type: "embedded-objects",
        object_name: "my-embedded-object",
      )

      render_inline component

      assert_no_selector ".govuk-summary-list__row[data-embed-code-row='true']", text: content_block_edition.document.embed_code_for_field("embedded-objects/my-embedded-object/name")
      assert_no_selector ".govuk-summary-list__row[data-embed-code-row='true']", text: content_block_edition.document.embed_code_for_field("embedded-objects/my-embedded-object/field-2")

      assert_selector ".govuk-summary-list__row[data-embed-code-row='true']", text: content_block_edition.document.embed_code_for_field("embedded-objects/my-embedded-object/field-1")
    end
  end

  describe "when card is editable" do
    it "renders a summary list with edit link" do
      component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
        content_block_edition:,
        object_type: "embedded-objects",
        object_name: "my-embedded-object",
        is_editable: true,
      )

      render_inline component

      assert_selector ".govuk-summary-card__title", text: "Embedded Object details"

      expected_edit_path = edit_embedded_object_content_block_manager_content_block_edition_path(
        content_block_edition,
        object_type: "embedded-objects",
        object_name: "my-embedded-object",
      )

      assert_selector ".govuk-summary-list__row", count: 3

      assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(1) a[href='#{expected_edit_path}']", text: "Edit"

      assert_selector ".govuk-summary-list__row", text: /Name/ do
        assert_selector ".govuk-summary-list__key", text: "Name"
        assert_selector ".govuk-summary-list__value", text: "My Embedded Object"
      end

      assert_selector ".govuk-summary-list__row", text: /Field 1/ do
        assert_selector ".govuk-summary-list__key", text: "Field 1"
        assert_selector ".govuk-summary-list__value", text: "Value 1"
      end

      assert_selector ".govuk-summary-list__row", text: /Field 2/ do
        assert_selector ".govuk-summary-list__key", text: "Field 2"
        assert_selector ".govuk-summary-list__value", text: "Value 2"
      end
    end

    it "renders a summary list with edit link and redirect url if provided" do
      component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
        content_block_edition:,
        object_type: "embedded-objects",
        object_name: "my-embedded-object",
        is_editable: true,
        redirect_url: "https://example.com",
      )

      render_inline component

      assert_selector ".govuk-summary-card__title", text: "Embedded Object details"

      expected_edit_path = edit_embedded_object_content_block_manager_content_block_edition_path(
        content_block_edition,
        object_type: "embedded-objects",
        object_name: "my-embedded-object",
        redirect_url: "https://example.com",
      )

      assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(1) a[href='#{expected_edit_path}']", text: "Edit"
    end

    it "does not render copy code button" do
      component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
        content_block_edition:,
        object_type: "embedded-objects",
        object_name: "my-embedded-object",
        is_editable: true,
      )

      render_inline component

      assert_no_selector ".govuk-summary-list__row[data-embed-code='#{content_block_edition.document.embed_code_for_field('embedded-objects/my-embedded-object/name')}']", text: "Name"
      assert_no_selector ".govuk-summary-list__row[data-embed-code='#{content_block_edition.document.embed_code_for_field('embedded-objects/my-embedded-object/field-1')}']", text: "Field 1"
      assert_no_selector ".govuk-summary-list__row[data-embed-code='#{content_block_edition.document.embed_code_for_field('embedded-objects/my-embedded-object/field-2')}']", text: "Field 2"
    end

    it "does not embed code row" do
      component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
        content_block_edition:,
        object_type: "embedded-objects",
        object_name: "my-embedded-object",
        is_editable: true,
      )

      render_inline component

      assert_no_selector ".govuk-summary-list__row[data-embed-code-row='true']", text: content_block_edition.document.embed_code_for_field("embedded-objects/my-embedded-object/name")
      assert_no_selector ".govuk-summary-list__row[data-embed-code-row='true']", text: content_block_edition.document.embed_code_for_field("embedded-objects/my-embedded-object/field-1")
      assert_no_selector ".govuk-summary-list__row[data-embed-code-row='true']", text: content_block_edition.document.embed_code_for_field("embedded-objects/my-embedded-object/field-2")
    end
  end
end
