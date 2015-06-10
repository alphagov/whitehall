require "test_helper"
require "gds_api/test_helpers/publishing_api"

class WithdrawingTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  test "When an edition is withdrawn, it gets republished to the Publishing API with an withdrawn notice" do
    edition   = create(:published_case_study)
    presenter = PublishingApiPresenters.presenter_for(edition)
    edition.build_unpublishing(explanation: 'Old information',
      unpublishing_reason_id: UnpublishingReason::Withdrawn.id)

    stub_panopticon_registration(edition)
    perform_withdrawal(edition)

    republish_url = Plek.current.find('publishing-api') + "/content" + presenter.base_path

    assert_requested(:put, republish_url) { |req| archived_payload?(req.body) }
  end

private

  def perform_withdrawal(edition)
    withdrawer = Whitehall.edition_services.withdrawer(edition)
    raise "Could not withdraw edition #{withdrawer.failure_reason}" unless withdrawer.perform!
  end

  def archived_payload?(json)
    payload = JSON.parse(json)
    payload['update_type'] == 'republish' &&
      payload['details']['withdrawn_notice'].is_a?(Hash)
  end
end
