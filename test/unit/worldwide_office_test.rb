require 'test_helper'

class WorldwideOfficeTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name, :summary, :description
  should_have_social_media
  should_have_contacts

  test "should set a slug from the field name" do
    office = create(:worldwide_office, name: 'Office Name')
    assert_equal 'office-name', office.slug
  end

  %w{name summary description}.each do |param|
    test "should not be valid without a #{param}" do
      refute build(:worldwide_office, param.to_sym => '').valid?
    end
  end

  test 'can be associated with multiple world locations' do
    countries = [
      create(:country, name: 'France'),
      create(:country, name: 'Spain')
    ]
    office = create(:worldwide_office, name: 'Office Name', world_locations: countries)

    assert_equal countries.sort_by(&:name), office.world_locations.sort_by(&:name)
  end
end
