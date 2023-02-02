require "test_helper"

class Admin::LegacyDetailedGuidesControllerTest < ActionController::TestCase
  tests Admin::DetailedGuidesController

  include GdsApi::TestHelpers::PublishingApi

  setup do
    login_as create(:writer, organisation: create(:organisation))
    create(:government)
    stub_request(
      :get,
      %r{\A#{Plek.find('publishing-api')}/v2/links},
    ).to_return(body: { links: {} }.to_json)
    stub_publishing_api_has_linkables([], document_type: "need")
  end

  legacy_should_be_an_admin_controller

  legacy_should_allow_creating_of :detailed_guide
  legacy_should_allow_editing_of :detailed_guide

  legacy_should_allow_organisations_for :detailed_guide
  legacy_should_allow_attached_images_for :detailed_guide
  legacy_should_prevent_modification_of_unmodifiable :detailed_guide
  legacy_should_allow_association_with_related_mainstream_content :detailed_guide
  legacy_should_allow_alternative_format_provider_for :detailed_guide
  legacy_should_allow_scheduled_publication_of :detailed_guide
  legacy_should_allow_overriding_of_first_published_at_for :detailed_guide
  legacy_should_allow_access_limiting_of :detailed_guide

private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id,
    )
  end
end
