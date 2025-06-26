require "test_helper"

class ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  let(:details) do
    {
      "embedded-objects" => {
        "my-embedded-object" => {
          "name" => "My Embedded Object",
          "field-2" => "Value 2",
          "field-1" => "Value 1",
        },
      },
    }
  end

  let(:schema) { stub(:schema) }
  let(:fields) do
    [
      stub("field", name: "name"),
      stub("field", name: "field-1"),
      stub("field", name: "field-2"),
    ]
  end
  let(:subschema) { stub(:subschema, embeddable_fields: %w[name field-1 field-2], fields:) }
  let(:document) { build(:content_block_document, :pension, schema:) }
  let(:content_block_edition) { build_stubbed(:content_block_edition, :pension, details:, document:) }

  before do
    schema.stubs(:subschema).returns(subschema)
  end

  it "renders a summary list" do
    component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
      content_block_edition:,
      object_type: "embedded-objects",
      object_title: "my-embedded-object",
    )

    render_inline component

    assert_selector ".govuk-summary-card__title", text: "Embedded Object details"

    assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_name']", text: /Name/ do
      assert_selector ".govuk-summary-list__key", text: "Name"
      assert_selector ".govuk-summary-list__value", text: "My Embedded Object"
    end

    assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_field_1']", text: /Field 1/ do
      assert_selector ".govuk-summary-list__key", text: "Field 1"
      assert_selector ".govuk-summary-list__value", text: "Value 1"
    end

    assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_field_2']", text: /Field 2/ do
      assert_selector ".govuk-summary-list__key", text: "Field 2"
      assert_selector ".govuk-summary-list__value", text: "Value 2"
    end
  end

  it "adds a data attribute if test_id_prefix is set" do
    component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
      content_block_edition:,
      object_type: "embedded-objects",
      object_title: "my-embedded-object",
      test_id_prefix: "prefix",
    )

    render_inline component

    assert_selector ".govuk-summary-card[data-test-id='prefix_my-embedded-object']"
  end

  describe "when there is a translated value" do
    it "returns a translated value" do
      I18n.expects(:t).with("content_block_edition.details.labels.embedded-objects.name", default: "Name").returns("Name")
      I18n.expects(:t).with("content_block_edition.details.labels.embedded-objects.field-1", default: "Field 1").returns("Field 1")
      I18n.expects(:t).with("content_block_edition.details.labels.embedded-objects.field-2", default: "Field 2").returns("Field 2")

      I18n.expects(:t).with("content_block_edition.details.values.My Embedded Object", default: "My Embedded Object").returns("My Embedded Object translated")
      I18n.expects(:t).with("content_block_edition.details.values.Value 2", default: "Value 2").returns("Value 2 translated")
      I18n.expects(:t).with("content_block_edition.details.values.Value 1", default: "Value 1").returns("Value 1 translated")

      component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
        content_block_edition:,
        object_type: "embedded-objects",
        object_title: "my-embedded-object",
        test_id_prefix: "prefix",
      )

      render_inline component

      assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_name']", text: /Name/ do
        assert_selector ".govuk-summary-list__value", text: "My Embedded Object translated"
      end

      assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_field_1']", text: /Field 1/ do
        assert_selector ".govuk-summary-list__value", text: "Value 1 translated"
      end

      assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_field_2']", text: /Field 2/ do
        assert_selector ".govuk-summary-list__value", text: "Value 2 translated"
      end
    end
  end

  it "renders a summary list with a collection" do
    component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.with_collection(
      %w[my-embedded-object],
      content_block_edition:,
      object_type: "embedded-objects",
    )

    render_inline component

    assert_selector ".govuk-summary-card__title", text: "Embedded Object details"
    assert_selector ".govuk-summary-list__row", count: 3
  end

  it "renders a summary list with edit link" do
    component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
      content_block_edition:,
      object_type: "embedded-objects",
      object_title: "my-embedded-object",
    )

    render_inline component

    assert_selector ".govuk-summary-card__title", text: "Embedded Object details"

    expected_edit_path = edit_embedded_object_content_block_manager_content_block_edition_path(
      content_block_edition,
      object_type: "embedded-objects",
      object_title: "my-embedded-object",
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
      object_title: "my-embedded-object",
      redirect_url: "https://example.com",
    )

    render_inline component

    assert_selector ".govuk-summary-card__title", text: "Embedded Object details"

    expected_edit_path = edit_embedded_object_content_block_manager_content_block_edition_path(
      content_block_edition,
      object_type: "embedded-objects",
      object_title: "my-embedded-object",
      redirect_url: "https://example.com",
    )

    assert_selector ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(1) a[href='#{expected_edit_path}']", text: "Edit"
  end

  describe "when arrays are present" do
    let(:fields) do
      [
        stub("field", name: "name"),
        stub("field", name: "field"),
      ]
    end

    let(:details) do
      {
        "embedded-objects" => {
          "my-embedded-object" => {
            "name" => "My Embedded Object",
            "field" => %w[Foo Bar],
          },
        },
      }
    end

    it "renders a summary list" do
      component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
        content_block_edition:,
        object_type: "embedded-objects",
        object_title: "my-embedded-object",
      )

      render_inline component

      assert_selector ".govuk-summary-card__title", text: "Embedded Object details"

      assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_name']", text: /Name/ do
        assert_selector ".govuk-summary-list__key", text: "Name"
        assert_selector ".govuk-summary-list__value", text: "My Embedded Object"
      end

      assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_field/0']", text: /Field 1/ do
        assert_selector ".govuk-summary-list__key", text: "Field 1"
        assert_selector ".govuk-summary-list__value", text: "Foo"
      end

      assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_field/1']", text: /Field 2/ do
        assert_selector ".govuk-summary-list__key", text: "Field 2"
        assert_selector ".govuk-summary-list__value", text: "Bar"
      end
    end

    describe "when arrays are present with hashes" do
      let(:fields) do
        [
          stub("field", name: "name"),
          stub("field", name: "field"),
        ]
      end

      let(:details) do
        {
          "embedded-objects" => {
            "my-embedded-object" => {
              "name" => "My Embedded Object",
              "field" => [{ item: "Foo" }, { item: "Bar" }],
            },
          },
        }
      end

      it "renders a nested summary card" do
        component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
          content_block_edition:,
          object_type: "embedded-objects",
          object_title: "my-embedded-object",
        )

        render_inline component

        assert_selector ".govuk-summary-card__title", text: "Embedded Object details"

        assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_name']", text: /Name/ do
          assert_selector ".govuk-summary-list__key", text: "Name"
          assert_selector ".govuk-summary-list__value", text: "My Embedded Object"
        end

        assert_selector ".app-c-content-block-manager-nested-item-component", text: /Field 1/ do |nested_block|
          nested_block.assert_selector ".govuk-summary-card__title", text: "Field 1"
          nested_block.assert_selector ".govuk-summary-list__key", text: "Item"
          nested_block.assert_selector ".govuk-summary-list__value", text: "Foo"
        end

        assert_selector ".app-c-content-block-manager-nested-item-component", text: /Field 2/ do |nested_block|
          nested_block.assert_selector ".govuk-summary-card__title", text: "Field 2"
          nested_block.assert_selector ".govuk-summary-list__key", text: "Item"
          nested_block.assert_selector ".govuk-summary-list__value", text: "Bar"
        end
      end

      it "returns a translated field if there is one present" do
        I18n.expects(:t).with("content_block_edition.details.labels.embedded-objects.name", default: "Name").returns("Name translated")
        I18n.expects(:t).with("content_block_edition.details.labels.item", default: "Item").returns("Item translated")
        I18n.expects(:t).with("content_block_edition.details.labels.item", default: "Item").returns("Item translated")

        I18n.expects(:t).with("content_block_edition.details.values.My Embedded Object", default: "My Embedded Object").returns("My Embedded Object")

        component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
          content_block_edition:,
          object_type: "embedded-objects",
          object_title: "my-embedded-object",
        )

        render_inline component

        assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_name']", text: /Name/ do
          assert_selector ".govuk-summary-list__key", text: "Name translated"
        end

        assert_selector ".app-c-content-block-manager-nested-item-component", text: /Field 1/ do |nested_block|
          nested_block.assert_selector ".govuk-summary-list__key", text: "Item translated"
        end

        assert_selector ".app-c-content-block-manager-nested-item-component", text: /Field 2/ do |nested_block|
          nested_block.assert_selector ".govuk-summary-list__key", text: "Item translated"
        end
      end
    end

    describe "when hashes are present" do
      let(:fields) do
        [
          stub("field", name: "name"),
          stub("field", name: "field"),
        ]
      end

      let(:details) do
        {
          "embedded-objects" => {
            "my-embedded-object" => {
              "name" => "My Embedded Object",
              "field" => { item: "Foo" },
            },
          },
        }
      end

      it "renders a nested summary card" do
        component = ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.new(
          content_block_edition:,
          object_type: "embedded-objects",
          object_title: "my-embedded-object",
        )

        render_inline component

        assert_selector ".govuk-summary-card__title", text: "Embedded Object details"

        assert_selector ".govuk-summary-list__row[data-testid='my_embedded_object_name']", text: /Name/ do
          assert_selector ".govuk-summary-list__key", text: "Name"
          assert_selector ".govuk-summary-list__value", text: "My Embedded Object"
        end

        assert_selector ".app-c-content-block-manager-nested-item-component", text: /Field/ do |nested_block|
          nested_block.assert_selector ".govuk-summary-card__title", text: "Field"
          nested_block.assert_selector ".govuk-summary-list__key", text: "Item"
          nested_block.assert_selector ".govuk-summary-list__value", text: "Foo"
        end
      end
    end
  end
end
