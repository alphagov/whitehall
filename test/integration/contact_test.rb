require "test_helper"

class ContactTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    stub_any_publishing_api_call

    @organisation_content_id = SecureRandom.uuid
    @world_location_content_id = SecureRandom.uuid

    world_location = FactoryGirl.create(:world_location,
                                        content_id: @world_location_content_id,
                                        title: "United Kingdom")

    @contact = FactoryGirl.build(:contact,
                                 title: "Government Digital Service",
                                 recipient: "GDS mail room",
                                 street_address: "Aviation House, 125 Kingsway",
                                 postal_code: "WC2B 6NH",
                                 country: world_location,
                                 email: "gds-mailroom@digital.cabinet-office.gov.uk")

    @contact.contactable = FactoryGirl.create(:organisation, content_id: @organisation_content_id)
  end

  test "When a contact is saved, a 'contact' content item is published to the Publishing API" do
    @contact.save!

    assert_publishing_api_put_content(@contact.content_id,
                                      request_json_includes(
                                        title: "Government Digital Service",
                                        schema_name: "contact",
                                        document_type: "contact",
                                        locale: "en",
                                        publishing_app: "whitehall"
                                      ))

    assert_publishing_api_patch_links(@contact.content_id,
                                      {
                                        links: {
                                          organisations: [@organisation_content_id],
                                          world_locations: [@world_location_content_id]
                                        }
                                      })

    assert_publishing_api_publish(@contact.content_id)
  end
end
