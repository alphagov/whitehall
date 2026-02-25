require "test_helper"

class ConfigurableContentBlocks::OrderedSelectWithSearchTaggingTest < ActionView::TestCase
  setup do
    @fields = {
      "world_locations" => {
        "title" => "Test attribute",
        "description" => "A test attribute",
        "required" => true,
        "block" => "ordered_select_with_search_tagging",
        "attribute_path" => %w[world_location_ids],
        "container" => "world_locations",
        "size" => 4,
      },
    }
    @path = Path.new(%w[world_location_ids])
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "forms" => {
        "documents" => {
          "fields" => @schema,
        },
      },
    }))
  end

  test "it renders the configured number of select inputs with the correct label, name and options from the container" do
    options = 1.upto(3).map { |index| build(:world_location, id: index) }

    edition = StandardEdition.new
    edition.world_locations = [options.first, options.last]
    block = ConfigurableContentBlocks::OrderedSelectWithSearchTagging.new(edition, @fields["world_locations"], @path)
    block.stubs("cached_taggable_world_locations").returns(options)

    render block

    assert_dom "legend", text: "Test attribute (required)"
    assert_dom "label", text: "Test attribute 1 (required)"

    select_selector = "select[name='edition[world_location_ids][]']#edition_world_location_ids_"

    1.upto(@fields["world_locations"]["size"]) do |index|
      assert_dom "#{select_selector}#{index}"
    end

    assert_dom "#{select_selector}1 option[selected=\"selected\"][value=\"#{options.first.id}\"]", text: options.first.name
    assert_dom "#{select_selector}2 option[selected=\"selected\"][value=\"#{options.last.id}\"]", text: options.last.name
  end

  test "it displays validation errors, using the title of the form input in the message" do
    messages = %w[foo bar]
    edition = StandardEdition.new
    messages.each { |m| edition.errors.add(:world_location_ids, m) }
    block = ConfigurableContentBlocks::OrderedSelectWithSearchTagging.new(edition, @fields["world_locations"], @path)

    render block

    assert_dom ".govuk-error-message", text: "Error: #{messages.map { |m| "Test attribute #{m}" }.join}"
  end
end
