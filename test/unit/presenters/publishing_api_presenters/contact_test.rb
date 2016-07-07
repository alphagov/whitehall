require 'test_helper'

class PublishingApiPresenters::ContactTest < ActiveSupport::TestCase
  setup do
    @organisation_content_id = SecureRandom.uuid
    @world_location_content_id = SecureRandom.uuid

    world_location = FactoryGirl.build(:world_location,
                                       content_id: @world_location_content_id,
                                       title: "United Kingdom")

    @contact = FactoryGirl.build(:contact,
                                 title: "Government Digital Service",
                                 recipient: "GDS mail room",
                                 street_address: "Aviation House, 125 Kingsway",
                                 postal_code: "WC2B 6NH",
                                 country: world_location,
                                 contact_numbers: [
                                   ContactNumber.new(label: "Mail Room", number: "+44 12345 67890")
                                 ],
                                 email: "gds-mailroom@digital.cabinet-office.gov.uk")

    @updated_at = Time.zone.parse("2016-06-23 10:32:00")
    @contact.translation.updated_at = @updated_at
    @contact.contactable = FactoryGirl.build(:organisation, content_id: @organisation_content_id)
    @presented = PublishingApiPresenters::Contact.new(@contact, {})
  end

  test "contact presentation includes the correct values" do
    expected_content = {
      title: "Government Digital Service",
      schema_name: "contact",
      document_type: "contact",
      locale: "en",
      phase: "live",
      public_updated_at: @updated_at,
      rendering_app: "government-frontend",
      publishing_app: "whitehall",
      details: {
        description: nil,
        contact_type: 1,
        post_addresses: [
          {
            title: "GDS mail room",
            street_address: "Aviation House, 125 Kingsway",
            locality: nil,
            postal_code: "WC2B 6NH",
            world_location: "United Kingdom",
          }
        ],
        email_addresses: [
          {
            title: "GDS mail room",
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
  end

  test "links hash includes organisations" do
    expected_links = {
      organisations: [@organisation_content_id],
      world_locations: [@world_location_content_id],
    }

    assert_equal expected_links, @presented.links
  end
end
