require 'test_helper'

class PublishingApiPresenters::PublishIntentTest < ActiveSupport::TestCase

  def present(item)
    PublishingApiPresenters::PublishIntent.new(item).as_json
  end

  test 'presents an intent to publish at the schedule time' do
    schedule_time = 2.days.from_now
    item = create(:scheduled_case_study, scheduled_publication: schedule_time)
    public_path = Whitehall.url_maker.public_document_path(item)
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
    assert_equal expected_hash, present(item)
  end
end
