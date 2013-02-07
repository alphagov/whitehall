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

  test "has an overridable default main contact" do
    office = create(:worldwide_office)

    assert_nil office.main_contact

    contact1 = create(:contact, title: 'Office 1')
    office.contacts << contact1
    assert_equal contact1, office.main_contact

    contact2 = create(:contact, title: 'Office 2')
    office.contacts << contact2
    assert_equal contact1, office.main_contact

    office.main_contact = contact2
    assert_equal contact2, office.main_contact
  end

  test "distinguishes between the main contact and other contacts" do
    contacts = [build(:contact), build(:contact)]
    office = build(:worldwide_office, contacts: contacts, main_contact: contacts.last)

    assert office.is_main_contact?(contacts.last)
    refute office.is_main_contact?(contacts.first)
  end

  test "can list other contacts" do
    contacts = [build(:contact), build(:contact)]

    assert_equal [], build(:worldwide_office, contacts: []).other_contacts
    assert_equal [], build(:worldwide_office, contacts: contacts.take(1)).other_contacts
    assert_equal [contacts.last], build(:worldwide_office, contacts: contacts, main_contact: contacts.first).other_contacts
  end

end
