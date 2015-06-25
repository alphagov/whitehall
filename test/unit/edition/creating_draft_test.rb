require "test_helper"

class Edition::WorkflowTest < ActiveSupport::TestCase
  test "should build a draft copy of the existing edition with the supplied creator" do
    published_edition = create(:published_edition)
    new_creator = create(:writer)
    draft_edition = published_edition.create_draft(new_creator)

    refute draft_edition.published?
    refute draft_edition.submitted?
    assert_equal new_creator, draft_edition.creator
    assert_equal published_edition.title, draft_edition.title
    assert_equal published_edition.body, draft_edition.body
  end

  test "should raise an exception when attempting to build a draft copy of an draft edition" do
    draft_edition = create(:draft_edition)
    new_creator = create(:writer)
    e = assert_raise(RuntimeError) { draft_edition.create_draft(new_creator) }
    assert_equal "Cannot create new edition based on edition in the draft state", e.message
  end

  test "should raise an exception when attempting to build a draft copy of an superseded edition" do
    superseded_edition = create(:superseded_edition)
    new_creator = create(:writer)
    e = assert_raise(RuntimeError) { superseded_edition.create_draft(new_creator) }
    assert_equal "Cannot create new edition based on edition in the superseded state", e.message
  end

  test "should not copy create and update time when creating draft" do
    published_edition = create(:published_edition)
    Timecop.travel 1.minute.from_now
    draft_edition = published_edition.create_draft(create(:writer))

    refute_equal published_edition.created_at, draft_edition.created_at
    refute_equal published_edition.updated_at, draft_edition.updated_at
  end

  test "should not copy change note when creating draft" do
    published_edition = create(:published_edition, change_note: "change-note")
    draft_edition = published_edition.create_draft(create(:writer))

    assert draft_edition.change_note.nil?
  end

  test "should not copy minor change flag when creating draft" do
    published_edition = create(:published_edition, minor_change: true)
    draft_edition = published_edition.create_draft(create(:writer))

    assert_equal false, draft_edition.minor_change
  end

  test "should not copy force published flag when creating draft" do
    published_edition = create(:published_edition, force_published: true)
    draft_edition = published_edition.create_draft(create(:writer))

    refute draft_edition.force_published
  end

  test "should not copy scheduled_publication date when creating draft" do
    published_edition = create(:published_edition, scheduled_publication: 1.day.from_now)
    draft_edition = published_edition.create_draft(create(:writer))

    assert draft_edition.scheduled_publication.nil?
  end

  test "should copy time of first publication when creating draft" do
    published_edition = create(:published_edition, first_published_at: 1.week.ago)
    Timecop.travel 1.hour.from_now
    draft_edition = published_edition.create_draft(create(:writer))

    assert_equal published_edition.first_published_at, draft_edition.first_published_at
  end

  test "should build a draft copy with references to topics, organisations & world locations" do
    topic = create(:topic)
    organisation = create(:organisation)
    country = create(:world_location)

    published_publication = create(:published_publication, topics: [topic], organisations: [organisation], world_locations: [country])

    draft_publication = published_publication.create_draft(create(:writer))

    assert_equal [topic], draft_publication.topics
    assert_equal [organisation], draft_publication.organisations
    assert_equal [country], draft_publication.world_locations
  end

  test "should build a draft copy with copies of consultation participation" do
    consultation_participation = create(:consultation_participation, link_url: "http://link.com")
    published_consultation = create(:published_consultation, consultation_participation: consultation_participation)
    draft_consultation = published_consultation.create_draft(create(:writer))
    draft_consultation.change_note = 'change-note'

    assert draft_consultation.valid?

    assert new_consultation_participation = draft_consultation.consultation_participation
    refute_equal consultation_participation, new_consultation_participation
    assert_equal consultation_participation.link_url, new_consultation_participation.link_url
  end

  test "should build a draft copy preserving ordering with topic" do
    topic = create(:topic)
    published_publication = create(:published_publication, topics: [topic])
    association = topic.classification_memberships.where(edition_id: published_publication.id).first
    association.update_attributes(ordering: 31)

    draft_publication = published_publication.create_draft(create(:writer))

    new_association = topic.classification_memberships.where(edition_id: draft_publication.id).first
    assert_equal 31, new_association.ordering
  end

  test "should build a draft copy even if parent is invalid" do
    published_publication = create(:published_publication)
    published_publication.update_attributes(title: nil)
    refute published_publication.valid?
    draft_publication = published_publication.create_draft(create(:writer))
    assert draft_publication.persisted?
  end

  test "should build a draft copy with copies of translations" do
    editor = create(:gds_editor)
    spanish_translation_attributes = {
      title: 'spanish-title',
      summary: 'spanish-summary',
      body: 'spanish-body'
    }
    publication = create(:draft_publication)
    with_locale(:es) { publication.update_attributes!(spanish_translation_attributes) }
    force_publish(publication)

    assert_equal 2, publication.translations.length

    draft_publication = publication.create_draft(editor)

    assert_equal 2, draft_publication.translations.length
    with_locale(:es) do
      assert_equal 'spanish-title', draft_publication.title
      assert_equal 'spanish-summary', draft_publication.summary
      assert_equal 'spanish-body', draft_publication.body
    end
  end

  test "should copy logo url when creating draft " do
    published_edition = create(:published_edition, logo_url: 'logos/flag.jpeg')
    draft_edition = published_edition.create_draft(create(:writer))

    assert_equal 'logos/flag.jpeg', draft_edition.logo_url
  end
end
