require 'test_helper'

class WorldwideOfficeTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name, :summary, :description

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

  test "can be associated with one or more sponsoring organisations" do
    organisation = create(:organisation)
    office = create(:worldwide_office)
    office.sponsoring_organisations << organisation

    assert_equal [organisation], office.reload.sponsoring_organisations
  end

  test "destroy deletes sponsorships" do
    office = create(:worldwide_office, sponsoring_organisations: [create(:organisation)])
    office.destroy
    assert_equal 0, office.sponsorships.count
  end

end
