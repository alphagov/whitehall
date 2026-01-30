require "test_helper"
require "support/concerns/admin_edition_controller/creating_tests"
require "support/concerns/admin_edition_controller/edition_editing_tests"
require "support/concerns/admin_edition_controller/lead_and_supporting_organisations_tests"
require "support/concerns/admin_edition_controller/first_published_at_overriding_tests"
require "support/concerns/admin_edition_controller/related_mainstream_content_tests"
require "support/concerns/admin_edition_controller/alternative_format_provider_tests"
require "support/concerns/admin_edition_controller/access_limiting_tests"
require "support/concerns/admin_edition_controller/topical_event_documents_tests"
require "support/concerns/admin_edition_controller/govspeak_history_and_fact_checking_tabs_tests"

class Admin::DetailedGuidesControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::PublishingApi

  setup do
    login_as create(:writer, organisation: create(:organisation))
    create(:government)
    stub_request(
      :get,
      %r{\A#{Plek.find('publishing-api')}/v2/links},
    ).to_return(body: { links: {} }.to_json)
  end

  include AdminEditionController::CreatingTests
  include AdminEditionController::EditionEditingTests
  include AdminEditionController::LeadAndSupportingOrganisationsTests
  include AdminEditionController::FirstPublishedAtOverridingTests
  include AdminEditionController::RelatedMainstreamContentTests
  include AdminEditionController::AlternativeFormatProviderTests
  include AdminEditionController::AccessLimitingTests
  include AdminEditionController::TopicalEventDocumentsTests
  include AdminEditionController::GovspeakHistoryAndFactCheckingTabsTests

  should_be_an_admin_controller

  should_allow_scheduled_publication_of :detailed_guide

private

  def edition_type
    :detailed_guide
  end

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id,
    )
  end
end
