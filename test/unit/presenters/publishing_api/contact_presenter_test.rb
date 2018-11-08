require 'test_helper'

class PublishingApi::ContactPresenterTest < ActiveSupport::TestCase
  setup do
    @organisation_content_id = SecureRandom.uuid
    @world_location_content_id = SecureRandom.uuid

    world_location = FactoryBot.build(:world_location,
                                       content_id: @world_location_content_id,
                                       name: "United Kingdom",
                                       iso2: "GB")

    @contact = FactoryBot.build(:contact,
                                 title: "Government Digital Service",
                                 recipient: "GDS Mail Room",
                                 street_address: "Aviation House, 125 Kingsway",
                                 postal_code: "WC2B 6NH",
                                 country: world_location,
                                 contact_numbers: [
                                   ContactNumber.new(label: "Mail Room", number: "+44 12345 67890")
                                 ],
                                 comments: "Quiet at weekends",
                                 email: "gds-mailroom@digital.cabinet-office.gov.uk",
                                 contact_form_url: "https://www.gov.uk")

    @updated_at = Time.zone.parse("2016-06-23 10:32:00")
    @contact.translation.updated_at = @updated_at
    @contact.contactable = FactoryBot.build(:organisation, content_id: @organisation_content_id)
    @presented = PublishingApi::ContactPresenter.new(@contact, {})
  end

  test "contact presentation includes the correct values" do
    expected_content = {
      title: "Government Digital Service",
      description: "Quiet at weekends",
      schema_name: "contact",
      document_type: "contact",
      locale: "en",
      phase: "live",
      public_updated_at: @updated_at,
      publishing_app: "whitehall",
      update_type: "major",
      details: {
        description: "Quiet at weekends",
        title: "Government Digital Service",
        contact_type: "General contact",
        contact_form_links: [
          {
            link: "https://www.gov.uk",
          }
        ],
        post_addresses: [
          {
            title: "GDS Mail Room",
            street_address: "Aviation House, 125 Kingsway",
            postal_code: "WC2B 6NH",
            world_location: "United Kingdom",
            iso2_country_code: "gb",
          }
        ],
        email_addresses: [
          {
            title: "GDS Mail Room",
            email: "gds-mailroom@digital.cabinet-office.gov.uk",
          }
        ],
        phone_numbers: [
          {
            title: "Mail Room",
            number: "+44 12345 67890",
          }
        ],
      }
    }

    assert_equal expected_content, @presented.content
    assert_valid_against_schema(@presented.content, 'contact')
  end

  test "links hash includes organisations" do
    expected_links = {
      organisations: [@organisation_content_id],
      world_locations: [@world_location_content_id],
    }

    assert_equal expected_links, @presented.links
  end

  test "does not render empty postal addresses" do
    @contact.street_address = ""
    @contact.postal_code = ""

    assert @presented.content[:details][:post_addresses].empty?
  end

  test "removes or sets to null fields that could be empty strings" do
    @contact.comments = ""
    @contact.recipient = ""
    @contact.email = ""

    assert @presented.content[:description].nil?
    refute @presented.content[:details][:post_addresses][0].has_key?(:title)
    refute @presented.content[:details].has_key?(:email_addresses)
  end
end
