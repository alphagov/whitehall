require "test_helper"

class ConfigurableContentBlocks::OrderedSelectWithSearchTaggingTest < ActionView::TestCase
  include ConfigurableContentBlockSharedTests

  setup do
    @field = {
      "title" => "Test attribute",
      "description" => "A test attribute",
      "required" => true,
      "block" => "ordered_select_with_search_tagging",
      "attribute_path" => %w[world_location_ids],
      "translatable" => true,
      "container" => "world_locations",
      "size" => 4,
    }
    @path = Path.new(%w[world_location_ids])
    @edition = StandardEdition.new(configurable_document_type: "test_type")
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "forms" => {
        "documents" => {
          "fields" => { "world_locations" => @field },
        },
      },
    }))
    @options = 1.upto(3).map { |index| build(:world_location, id: index) }
    @content = [@options.first, @options.last]
  end

  test "it renders the configured number of select inputs with the correct label, name and options from the container" do
    fill_in_field
    WorldLocation.stubs(:ordered_by_name).returns(stub(where: @options))

    render block

    assert_dom "legend", text: "Test attribute (required)"
    assert_dom "label", text: "Test attribute 1 (required)"

    select_selector = "select[name='edition[world_location_ids][]']#edition_world_location_ids_"

    1.upto(@field["size"]) do |index|
      assert_dom "#{select_selector}#{index}"
    end

    assert_dom "#{select_selector}1 option[selected=\"selected\"][value=\"#{@options.first.id}\"]", text: @options.first.name
    assert_dom "#{select_selector}2 option[selected=\"selected\"][value=\"#{@options.last.id}\"]", text: @options.last.name
  end

  test "it displays validation errors, using the title of the form input in the message" do
    messages = %w[foo bar]
    messages.each { |m| @edition.errors.add(:world_location_ids, m) }

    render block

    assert_dom ".govuk-error-message", text: "Error: #{messages.map { |m| "Test attribute #{m}" }.join}"
  end

  def fill_in_field(edition = nil, content = nil)
    edition ||= @edition
    content ||= @content

    edition.world_locations = content
  end

  def field_with_value
    select_selector = "select[name='edition[world_location_ids][]']#edition_world_location_ids_"

    @content.each_with_index.map do |option, index|
      "#{select_selector}#{index + 1} option[selected=\"selected\"][value=\"#{option.id}\"]"
    end
  end

  def block
    ConfigurableContentBlocks::OrderedSelectWithSearchTagging.new(@edition, @field, @path)
  end
end
