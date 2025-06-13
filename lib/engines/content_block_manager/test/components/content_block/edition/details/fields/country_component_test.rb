require "test_helper"

class ContentBlockManager::ContentBlockEdition::Details::Fields::CountryComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :pension) }
  let(:field) { stub("field", name: "country", is_required?: true) }

  let(:world_locations) { build_list(:world_location, 5) }

  before do
    WorldLocation.stubs(:all).returns(world_locations)
  end

  it "should render an select field populated with WorldLocations" do
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
    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]"

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
    assert_selector "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]"

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
      ),
    )

    assert_selector ".govuk-form-group--error"
    assert_selector ".govuk-error-message", text: "Some error goes here"
    assert_selector "select.govuk-select--error"
  end
end
