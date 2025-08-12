require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::CountryComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :pension) }
  let(:field) { stub("field", name: "country", is_required?: true, default_value: nil) }

  let(:world_locations) { 5.times.map { |i| build(:world_location, name: "World location #{i}") } }
  let(:uk) { build(:world_location, name: "United Kingdom") }

  let(:all_locations) { [world_locations, uk].flatten }

  before do
    WorldLocation.stubs(:geographical).returns(all_locations)
  end

  it "should render an select field populated with WorldLocations with the UK as the blank option" do
    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::CountryComponent.new(
        content_block_edition:,
        field:,
      ),
    )

    expected_name = "content_block/edition[details][country]"
    expected_id = "#{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_country"

    assert_selector "label", text: "Country"
    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"

    assert_selector "select option", count: all_locations.count

    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]", text: uk.name

    world_locations.each do |location|
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"#{location.name}\"]", text: location.name
    end
  end

  it "should show an option as selected when value is given" do
    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::CountryComponent.new(
        content_block_edition:,
        field:,
        value: world_locations.first.name,
      ),
    )

    expected_name = "content_block/edition[details][country]"
    expected_id = "#{ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent::PARENT_CLASS}_details_country"

    assert_selector "label", text: "Country"
    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]", text: uk.name

    world_locations.each do |location|
      assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"#{location.name}\"]", text: location.name
    end

    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"#{world_locations.first.name}\"][selected]", text: world_locations.first.name
  end

  it "should show errors when present" do
    content_block_edition.errors.add(:details_country, "Some error goes here")

    render_inline(
      ContentBlockManager::ContentBlockEdition::Details::Fields::CountryComponent.new(
        content_block_edition:,
        field:,
        enum: %w[country],
      ),
    )

    assert_selector ".govuk-form-group--error"
    assert_selector ".govuk-error-message", text: "Some error goes here"
    assert_selector "select.govuk-select--error"
  end

  describe "#options" do
    it "returns a list of countries" do
      component = ContentBlockManager::ContentBlockEdition::Details::Fields::CountryComponent.new(
        content_block_edition:,
        field:,
      )

      expected = [
        { text: "United Kingdom", value: "", selected: false },
        { text: world_locations[0].name, value: world_locations[0].name, selected: false },
        { text: world_locations[1].name, value: world_locations[1].name, selected: false },
        { text: world_locations[2].name, value: world_locations[2].name, selected: false },
        { text: world_locations[3].name, value: world_locations[3].name, selected: false },
        { text: world_locations[4].name, value: world_locations[4].name, selected: false },
      ]

      assert_equal component.options, expected
    end

    it "sets an option as selected when value is provided" do
      component = ContentBlockManager::ContentBlockEdition::Details::Fields::CountryComponent.new(
        content_block_edition:,
        field:,
        value: world_locations.first.name,
      )

      expected = [
        { text: "United Kingdom", value: "", selected: false },
        { text: world_locations[0].name, value: world_locations[0].name, selected: true },
        { text: world_locations[1].name, value: world_locations[1].name, selected: false },
        { text: world_locations[2].name, value: world_locations[2].name, selected: false },
        { text: world_locations[3].name, value: world_locations[3].name, selected: false },
        { text: world_locations[4].name, value: world_locations[4].name, selected: false },
      ]

      assert_equal component.options, expected
    end
  end
end
