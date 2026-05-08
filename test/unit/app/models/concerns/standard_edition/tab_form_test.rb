require "test_helper"

class StandardEdition::TabFormTest < ActiveSupport::TestCase
  setup do
    @test_type = build_configurable_document_type(
      "test_type", {
        "forms" => {
          "documents" => {
            "fields" => {
              "body" => {
                "title" => "Body",
                "block" => "govspeak",
                "attribute_path" => %w[block_content body],
              },
              "lead_organisations" => {
                "title" => "Lead organisations",
                "block" => "ordered_select_with_search_tagging",
                "attribute_path" => %w[lead_organisation_ids],
              },
            },
          },
          "extra_tab" => {
            "label" => "Extra tab",
            "dynamic" => true,
            "fields" => {
              "sidebar" => {
                "title" => "Sidebar",
                "block" => "govspeak",
                "attribute_path" => %w[block_content sidebar],
              },
            },
          },
        },
        "schema" => {
          "attributes" => {
            "body" => { "type" => "string" },
            "sidebar" => { "type" => "string" },
          },
          "validations" => {
            "presence" => { "attributes" => %w[body sidebar] },
          },
        },
      }
    )
    ConfigurableDocumentType.setup_test_types(@test_type)
  end

  test "it is valid when all fields on a particular tab are present" do
    edition = build(:standard_edition, :with_organisations,
                    configurable_document_type: "test_type",
                    title: "Title", summary: "Summary",
                    block_content: { body: "Some body" })
    tab_form = StandardEdition::TabForm.new(edition, "documents")

    assert tab_form.valid?
  end

  test "it is invalid and adds an error when a required block_content field is blank" do
    edition = build(:standard_edition, :with_organisations,
                    configurable_document_type: "test_type",
                    title: "Title", summary: "Summary",
                    block_content: { body: "" })
    documents_tab_form = StandardEdition::TabForm.new(edition, "documents")
    extra_tab_form = StandardEdition::TabForm.new(edition, "extra_tab")

    assert documents_tab_form.invalid?
    assert_includes documents_tab_form.errors.full_messages, "Body cannot be blank"
    assert extra_tab_form.invalid?
    assert_includes extra_tab_form.errors.full_messages, "Sidebar cannot be blank"
  end

  test "it is invalid and adds an error when a required edition attribute field is blank" do
    edition = build(:standard_edition,
                    configurable_document_type: "test_type",
                    title: "Title", summary: "Summary",
                    block_content: { body: "Some body" })
    edition.lead_organisations = []

    tab_form = StandardEdition::TabForm.new(edition, "documents")
    assert tab_form.invalid?
    assert tab_form.errors.where(:lead_organisation_ids).any?
  end

  test "it validates title and summary on the default tab" do
    edition = build(:standard_edition,
                    configurable_document_type: "test_type",
                    title: "", summary: "",
                    block_content: { body: "Some body" })
    tab_form = StandardEdition::TabForm.new(edition, edition.default_tab)

    assert tab_form.invalid?
    assert tab_form.errors.where(:title).any?
    assert tab_form.errors.where(:summary).any?
  end

  test "it does not validate title and summary on non-default tabs" do
    edition = build(:standard_edition, :with_organisations,
                    configurable_document_type: "test_type",
                    title: "", summary: "",
                    block_content: { body: "Some body", sidebar: "Sidebar content" })

    tab_form = StandardEdition::TabForm.new(edition, "extra_tab")

    assert tab_form.valid?
  end

  test "it does not hold errors from fields on other tabs" do
    edition = build(:standard_edition, :with_organisations,
                    configurable_document_type: "test_type",
                    title: "Title", summary: "Summary",
                    block_content: { body: "", sidebar: "Sidebar content" })

    tab_form = StandardEdition::TabForm.new(edition, "extra_tab")

    assert tab_form.valid?
    assert tab_form.errors.where(:body).none?
  end
end
