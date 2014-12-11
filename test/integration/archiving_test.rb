require "test_helper"
require "gds_api/test_helpers/publishing_api"

class ArchivingTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "When an edition is archived, it gets published to the Publishing API with an archive notice" do
    edition   = create(:published_case_study)
    presenter = PublishingApiPresenters.presenter_for(edition)
    edition.build_unpublishing(explanation: 'Old information',
      unpublishing_reason_id: UnpublishingReason::Archived.id)

    stub_panopticon_registration(edition)
    perform_archiving(edition)

    publish_url = Plek.current.find('publishing-api') + "/content" + presenter.base_path

    assert_requested(:put, publish_url) { |req| archived_payload?(req.body) }
  end

private

  def perform_archiving(edition)
    archiver = Whitehall.edition_services.archiver(edition)
    raise "Could not archive edition #{archiver.failure_reason}" unless archiver.perform!
  end

  def archived_payload?(json)
    payload = JSON.parse(json)
    payload['update_type'] == 'major' &&
      payload['details']['archive_notice'].is_a?(Hash)
  end
end
