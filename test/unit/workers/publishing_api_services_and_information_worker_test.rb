require "test_helper"
require "gds_api/test_helpers/publishing_api_v2"

class PublishingApiServicesAndInformationWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  setup do
    @organisation = create(:organisation, name: "Organisation of Things", slug: "things")
    SecureRandom.stubs(uuid: "a-content-id")
    @payload = PublishingApi::ServicesAndInformationPresenter.new(@organisation)
  end

  test "publishes a services and information page for an eligible organisation" do
    stub_request(:post, "#{Plek.new.find('publishing-api')}/lookup-by-base-path")
      .to_return(body: {}.to_json)
    Organisation.any_instance.stubs(:has_services_and_information_link?).returns(true)

    put_content_request = stub_publishing_api_put_content("a-content-id", @payload.content)
    publish_request = stub_publishing_api_publish("a-content-id",
                                                  locale: "en",
                                                  update_type: nil)
    patch_links_request = stub_publishing_api_patch_links("a-content-id", links: @payload.links)

    PublishingApiServicesAndInformationWorker.new.perform(@organisation.id)

    assert_requested put_content_request
    assert_requested publish_request
    assert_requested patch_links_request
  end

  test "does not publish a services and information page for an ineligible organisation" do
    Organisation.any_instance.stubs(:has_services_and_information_link?).returns(false)

    put_content_request = stub_publishing_api_put_content("a-content-id", @payload.content)
    publish_request = stub_publishing_api_publish("a-content-id",
                                                  update_type: nil,
                                                  locale: "en")
    patch_links_request = stub_publishing_api_patch_links("a-content-id", links: @payload.links)

    PublishingApiServicesAndInformationWorker.new.perform(@organisation.id)

    assert_not_requested put_content_request
    assert_not_requested publish_request
    assert_not_requested patch_links_request
  end

  test "correctly re-publishes a services and information page" do
    stub_request(:post, "#{Plek.new.find('publishing-api')}/lookup-by-base-path")
      .to_return(body: {
        "/government/organisations/things/services-information": "another-content-id"
      }.to_json)
    Organisation.any_instance.stubs(:has_services_and_information_link?).returns(true)

    put_content_request = stub_publishing_api_put_content("another-content-id", @payload.content)
    publish_request = stub_publishing_api_publish("another-content-id",
                                                  update_type: nil,
                                                  locale: "en")
    patch_links_request = stub_publishing_api_patch_links("another-content-id", links: @payload.links)

    PublishingApiServicesAndInformationWorker.new.perform(@organisation.id)

    assert_requested put_content_request
    assert_requested publish_request
    assert_requested patch_links_request
  end
end
