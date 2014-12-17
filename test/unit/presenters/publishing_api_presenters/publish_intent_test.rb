require 'test_helper'

class PublishingApiPresenters::PublishIntentTest < ActiveSupport::TestCase

  def present(edition)
    PublishingApiPresenters::PublishIntent.new(edition).as_json
  end

  test 'presents an intent to publish at the schedule time' do
    schedule_time = 2.days.from_now
    edition = create(:scheduled_case_study, scheduled_publication: schedule_time)
    public_path = Whitehall.url_maker.public_document_path(edition)
    expected_hash = {
      base_path: public_path,
      publish_time: schedule_time,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      routes: [
        {
          path: public_path,
          type: "exact"
        }
      ]
    }
    assert_equal expected_hash, present(edition)
  end
end
