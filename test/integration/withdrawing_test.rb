require "test_helper"
require "gds_api/test_helpers/publishing_api"

class WithdrawingTest < ActiveSupport::TestCase
  test "When an edition is withdrawn, it gets republished to the Publishing API with an withdrawn notice" do
    edition   = create(:published_case_study)
    presenter = PublishingApiPresenters.presenter_for(edition, update_type: 'republish')
    edition.build_unpublishing(explanation: 'Old information',
      unpublishing_reason_id: UnpublishingReason::Withdrawn.id)

    stub_panopticon_registration(edition)

    content = presenter.content
    content[:details][:withdrawn_notice] = {
      explanation: "<div class=\"govspeak\"><p>Old information</p>\n</div>",
      withdrawn_at: edition.updated_at
    }

    requests = [
      stub_publishing_api_put_content(presenter.content_id, content),
      stub_publishing_api_put_links(presenter.content_id, links: presenter.links),
      stub_publishing_api_publish(presenter.content_id, locale: 'en', update_type: 'republish')
    ]

    perform_withdrawal(edition)

    assert_all_requested requests
  end

private

  def perform_withdrawal(edition)
    withdrawer = Whitehall.edition_services.withdrawer(edition)
    raise "Could not withdraw edition #{withdrawer.failure_reason}" unless withdrawer.perform!
  end
end
