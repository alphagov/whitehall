require 'test_helper'
require 'securerandom'

class PublishingApi::ComingSoonPresenterTest < ActiveSupport::TestCase
  setup do
    @publish_timestamp = 1.day.from_now
    @content_id = SecureRandom.uuid
    SecureRandom.stubs(uuid: @content_id)
    @edition = create(:scheduled_case_study,
                       title: 'Case study title',
                       summary: 'The summary',
                       body: 'Some content',
                       scheduled_publication: @publish_timestamp,
                     )
  end

  test 'presents a valid "coming_soon" content item' do
    public_path = '/government/case-studies/case-study-title'
    expected_hash = {
      base_path: public_path,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      schema_name: 'coming_soon',
      document_type: 'coming_soon',
      title: 'Coming soon',
      description: 'Coming soon',
      locale: 'en',
      details: { publish_time: @publish_timestamp },
      routes: [{ path: public_path, type: 'exact' }],
      redirects: [],
      public_updated_at: @edition.updated_at,
      update_type: "major",
    }

    presenter = PublishingApi::ComingSoonPresenter.new(@edition)

    assert_equal expected_hash, presenter.content
    assert_equal @content_id, presenter.content_id
    assert_valid_against_schema(presenter.content, 'coming_soon')
  end
end
