require 'test_helper'

class PublishingApiPresenters::UnpublishingTest < ActiveSupport::TestCase
  def present(edition, options = {})
    PublishingApiPresenters::Unpublishing.new(edition, options).as_json
  end

  test 'presents an unpublished edition' do
    case_study = create(:draft_case_study,
                        title: 'Case study title',
                        summary: 'The summary')
    unpublishing = create(:unpublishing, edition: case_study,
                          explanation: 'it is rubbish',
                          alternative_url: 'https://www.test.alphagov.co.uk/foobar')

    public_path = Whitehall.url_maker.public_document_path(case_study)
    expected_hash = {
      content_id: case_study.document.content_id,
      title: 'Case study title',
      description: 'The summary',
      base_path: public_path,
      format: 'unpublishing',
      locale: 'en',
      need_ids: [],
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: case_study.public_timestamp,
      update_type: 'major',
      routes: [
        { path: public_path, type: 'exact' }
      ],
      redirects: [],
      details: {
        explanation: 'it is rubbish',
        unpublished_at: unpublishing.created_at,
        alternative_url: 'https://www.test.alphagov.co.uk/foobar'
      }
    }

    assert_equal expected_hash, present(case_study)
  end
end
