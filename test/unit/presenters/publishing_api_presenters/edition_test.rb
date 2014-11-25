require 'test_helper'

class PublishingApiPresenters::EditionTest < ActiveSupport::TestCase

  def present(edition)
    PublishingApiPresenters::Edition.new(edition).as_json
  end

  test 'presents an Edition ready for adding to the publishing API' do
    edition = create(:published_publication,
                title: 'The title',
                summary: 'The summary',
                primary_specialist_sector_tag: 'oil-and-gas/taxation',
                secondary_specialist_sector_tags: ['oil-and-gas/licensing'])

    public_path = Whitehall.url_maker.public_document_path(edition)

    expected_hash = {
      content_id: edition.document.content_id,
      title: 'The title',
      description: 'The summary',
      base_path: public_path,
      format: 'placeholder',
      need_ids: [],
      public_updated_at: edition.public_timestamp,
      update_type: 'major',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      routes: [
        { path: public_path, type: 'exact' }
      ],
      redirects: [],
      details: {
        change_note: nil,
        tags: {
          browse_pages: [],
          topics: ['oil-and-gas/taxation', 'oil-and-gas/licensing']
        }
      },
    }

    assert_equal expected_hash, present(edition)
  end

  test 'includes the most recent change note even when the edition is only a minor change' do
    user  = create(:gds_editor)
    first = create(:published_edition)

    major = first.create_draft(user)
    major.change_note = 'This was a major change'
    force_publish(major)

    minor = major.create_draft(user)
    minor.minor_change = true
    minor.change_note = nil

    assert_equal 'This was a major change', present(minor)[:details][:change_note]
  end

  test 'minor changes are a "minor" update type' do
    edition = create(:case_study, minor_change: true)
    assert_equal 'minor', present(edition)[:update_type]
  end
end
