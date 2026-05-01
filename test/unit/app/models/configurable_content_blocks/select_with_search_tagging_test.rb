require "test_helper"

class ConfigurableContentBlocks::SelectWithSearchTaggingTest < ActionView::TestCase
  include ConfigurableContentBlockSharedTests

  setup do
    @field = {
      "title" => "Test attribute",
      "description" => "A test attribute",
      "required" => true,
      "block" => "select_with_search_tagging",
      "attribute_path" => %w[worldwide_organisation_document_ids],
      "translatable" => true,
      "container" => "worldwide_organisations",
    }
    @path = Path.new(%w[worldwide_organisation_document_ids])
    @edition = StandardEdition.new(configurable_document_type: "test_type")
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "forms" => {
        "documents" => {
          "fields" => { "worldwide_organisations" => @field },
        },
      },
    }))
    @block = ConfigurableContentBlocks::SelectWithSearchTagging.new(@edition, @field, @path)
  end

  test "it renders a select with the correct label, name and options from the container" do
    options = build_list(:worldwide_organisation, 3)
    options.each_with_index { |wo, index| wo.document = build(:document, id: index) }

    @edition.worldwide_organisation_documents = [options.first.document, options.last.document]
    WorldwideOrganisation.stubs(:with_translations).returns(stub(latest_edition: options))

    render @block

    assert_dom "label", text: "Test attribute (required)"
    # The select with search component adds the trailing [] on to the select name automatically, but not the search input.
    # If the input doesn't have it as well, Rails treats the parameter as a string and this causes a controller params error
    # because the controller expects an array
    assert_dom "input[name='edition[worldwide_organisation_document_ids][]']"
    assert_dom "select[name='edition[worldwide_organisation_document_ids][]']"
    options.each do |option|
      selected_attr = @edition.worldwide_organisation_documents.include?(option.document) ? "[selected=\"selected\"]" : ""
      assert_dom "option#{selected_attr}[value=\"#{option.document.id}\"]", text: option.title
    end
  end

  test "it displays validation errors, using the title of the form input in the message" do
    messages = %w[foo bar]
    messages.each { |m| @edition.errors.add(:worldwide_organisation_document_ids, m) }

    render @block

    assert_dom ".govuk-error-message", text: "Error: #{messages.map { |m| "Test attribute #{m}" }.join}"
  end
end
