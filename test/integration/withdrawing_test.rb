require "test_helper"
require "gds_api/test_helpers/publishing_api"

class WithdrawingTest < ActiveSupport::TestCase
  test "When an edition is withdrawn, it gets republished to the Publishing API with an withdrawn notice" do
    edition   = create(:published_case_study)
    edition.build_unpublishing(explanation: 'Old information',
      unpublishing_reason_id: UnpublishingReason::Withdrawn.id)

    request = stub_publishing_api_unpublish(
      edition.content_id,
      body: {
        type: "withdrawal",
        locale: "en",
        explanation: "<div class=\"govspeak\"><p>Old information</p>\n</div>",
        unpublished_at: edition.updated_at.utc.iso8601,
      }
    )

    perform_withdrawal(edition)

    assert_requested request
  end

private

  def perform_withdrawal(edition)
    withdrawer = Whitehall.edition_services.withdrawer(edition)
    raise "Could not withdraw edition #{withdrawer.failure_reason}" unless withdrawer.perform!
  end
end
