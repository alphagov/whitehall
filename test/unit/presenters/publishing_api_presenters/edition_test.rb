require 'test_helper'

class PublishingApiPresenters::EditionTest < ActiveSupport::TestCase

  def present(edition, options={})
    PublishingApiPresenters::Edition.new(edition, options).as_json
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
      format: 'placeholder',
      locale: 'en',
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

  test 'update type can be overridden by passing an update_type option' do
    update_type_override = 'republish'
    edition = create(:case_study)
    presented_hash = present(edition, update_type: update_type_override)
    assert_equal update_type_override, presented_hash[:update_type]
  end

  test 'is locale aware' do
    edition = create(:publication)

    I18n.with_locale :ur do
      edition.title = "Urdu title"
      edition.save!
      presented_hash = present(edition)

      assert_equal 'ur', presented_hash[:locale]
      assert_equal 'Urdu title', presented_hash[:title]
      assert_equal Whitehall.url_maker.public_document_path(edition, locale: :ur),
        presented_hash[:routes].first[:path]

    end
  end
end
