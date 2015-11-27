require "test_helper"
require "gds_api/test_helpers/publishing_api"

class WithdrawingTest < ActiveSupport::TestCase
  test "When an edition is withdrawn, it gets republished to the Publishing API with an withdrawn notice" do
    edition   = create(:published_case_study)
    presenter = PublishingApiPresenters.presenter_for(edition)
    edition.build_unpublishing(explanation: 'Old information',
      unpublishing_reason_id: UnpublishingReason::Withdrawn.id)

    stub_panopticon_registration(edition)
    publishing_api_payload = presenter.as_json.tap { |json|
      json[:details][:withdrawn_notice] = {
        explanation: "<div class=\"govspeak\"><p>Old information</p>\n</div>",
        withdrawn_at: edition.updated_at
      }
      json[:update_type] = "republish"
    }
    requests = stub_publishing_api_put_content_links_and_publish(publishing_api_payload)
    perform_withdrawal(edition)

    requests.each { |request| assert_requested request }
  end

private

  def perform_withdrawal(edition)
    withdrawer = Whitehall.edition_services.withdrawer(edition)
    raise "Could not withdraw edition #{withdrawer.failure_reason}" unless withdrawer.perform!
  end
end
