require "test_helper"

class Edition::IdentifiableTest < ActiveSupport::TestCase
  test "should set document type on document before validation for use in slug duplicate detection" do
    publication = build(:publication)
    publication.valid?
    assert_equal "Publication", publication.document.document_type
  end

  test "should not attempt to set document type if document is not present" do
    publication = build(:publication)
    publication.stubs(:document).returns(nil)
    assert_nothing_raised { publication.valid? }
  end

  test "should generate a content_id for the document of a new draft" do
    publication = build(:publication)
    publication.valid?
    assert publication.document.content_id.present?
  end

  test "should generate a content_id and slug on a document when present" do
    document = build(:document, content_id: nil, slug: nil)
    publication = build(:publication, document:)
    publication.valid?
    assert publication.document.content_id.present?
    assert publication.document.slug.present?
  end

  test "should not allow the same slug to be used again for the same document type" do
    same_title = "same-title"
    publication1 = create(:publication, title: same_title)
    publication2 = create(:publication, title: same_title)

    assert_not_equal publication1.document.slug, publication2.document.slug
  end

  test "should allow the same slug to be used again for another document type" do
    same_title = "same-title"
    publication = create(:publication, title: same_title)
    news_article = create(:news_article, title: same_title)

    assert_equal publication.document.slug, news_article.document.slug
  end

  test "should return the edition of the correct type when matching slugs for other types exist" do
    same_title = "same-title"
    news_article = create(:published_news_article, title: same_title)
    publication = create(:published_publication, title: same_title)

    assert_equal news_article, NewsArticle.published_as(same_title)
    assert_equal publication, Publication.published_as(same_title)
  end

  test "should return nil if the edition isn't translated into the supplied locale" do
    publication = create(:published_publication, translated_into: "fr")

    assert_nil Publication.published_as(publication.slug, "zh")
  end

  test "should return the edition if it is translated into the supplied locale" do
    publication = create(:published_publication, translated_into: "fr")

    assert_equal publication, Publication.published_as(publication.slug, "fr")
  end

  test "should return the edition if it is translated into the default locale when none is specified" do
    publication = create(:published_publication, translated_into: I18n.default_locale)

    assert_equal publication, Publication.published_as(publication.slug)
  end

  test "should be linkable when draft if document is published" do
    publication = create(:published_publication)
    new_edition = publication.create_draft(create(:writer))
    assert new_edition.linkable?
  end

  test "should not be linkable if document is not published" do
    publication = create(:draft_publication)
    assert_not publication.linkable?
  end

  test "should be linkable when superseded if document is published" do
    publication = create(:published_publication)
    new_edition = publication.create_draft(create(:writer))
    new_edition.minor_change = true
    force_publish(new_edition)
    assert publication.linkable?
  end

  test "should be linkable if scheduled to be published within 5 seconds" do
    date = Date.new(2010, 1, 1, 9)
    publication = create(:scheduled_publication, scheduled_publication: date)
    Timecop.freeze(date - 5.seconds) do
      assert publication.linkable?
    end
  end

  test "do not update slug if non-english title changes on draft edition" do
    publication = create(:draft_publication, title: "This is my publication")
    with_locale(:es) do
      publication.update!(title: "Spanish thing", summary: "Avoid validation error", body: "Avoid validation error")
    end

    assert_equal "this-is-my-publication", publication.document.reload.slug
  end

  test "should not update the slug of an existing edition when saved in the presence of a new edition with the same title" do
    existing_edition = create(:draft_publication, title: "This is my publication")
    assert_equal "this-is-my-publication", existing_edition.document.reload.slug

    new_edition_with_same_title = create(:draft_publication, title: "This is my publication")
    assert_equal "this-is-my-publication--2", new_edition_with_same_title.document.reload.slug

    existing_edition.save!
    assert_equal "this-is-my-publication", existing_edition.document.reload.slug
  end

  test "update slug if title changes on draft edition" do
    publication = create(:draft_publication, title: "This is my publication")
    publication.update!(title: "Another thing")

    assert_equal "another-thing", publication.document.reload.slug
  end

  test "can publish an edition with an updated slug" do
    edition = create(:submitted_publication, title: "First Title")
    edition.save_as(user = create(:user))

    edition.title = "Second Title"
    edition.save_as(user)
    publish(edition)

    assert_nil Publication.published_as("first-title")
    assert_equal edition, Publication.published_as("second-title")
  end

  test "can update slug after an edition has been unpublished" do
    Current.user = create(:user)
    unpublished_edition = create(:superseded_publication, title: "This is my publication")
    draft_edition = create(:draft_publication, title: "This is my publication", document: unpublished_edition.document)

    draft_edition.title = "New title"
    draft_edition.should_update_document_slug = true
    draft_edition.save!
    assert_equal "new-title", draft_edition.document.reload.slug
  end

  test "should not update slug if should_update_document_slug is false on a published edition" do
    published_edition = create(:published_publication, title: "Original title")
    original_slug = published_edition.document.slug

    draft_edition = published_edition.create_draft(create(:writer))
    draft_edition.update!(title: "New title", should_update_document_slug: false, change_note: "Changed title")

    assert_equal original_slug, draft_edition.document.reload.slug
  end

  test "should update slug if should_update_document_slug is true on a published edition" do
    Current.user = create(:user)
    published_edition = create(:published_publication, title: "Original title")

    draft_edition = published_edition.create_draft(create(:writer))
    draft_edition.update!(title: "New title", should_update_document_slug: true, change_note: "Changed title")

    assert_equal "new-title", draft_edition.document.reload.slug
  end

  test "should create editorial remark when slug is updated" do
    user = create(:user)
    Current.user = user
    published_edition = create(:published_publication, title: "Original title")
    draft_edition = published_edition.create_draft(user)

    draft_edition.update!(title: "New title", should_update_document_slug: true, change_note: "Changed title")
    editorial_remark = draft_edition.editorial_remarks.last

    assert editorial_remark.present?
    assert_match(/Title change created new slug:/, editorial_remark.body)
    assert_match(/new-title/, editorial_remark.body)
    assert_equal user, editorial_remark.author
  end

  test "should not create editorial remark if slug does not change" do
    publication = create(:draft_publication, title: "Original title")
    initial_remark_count = publication.editorial_remarks.count

    publication.should_update_document_slug = true
    publication.update!(summary: "Updated summary")

    assert_equal initial_remark_count, publication.editorial_remarks.count
  end

  test "should not create editorial remark if edition is the first draft" do
    publication = create(:draft_publication, title: "Original title")
    initial_remark_count = publication.editorial_remarks.count
    publication.update!(title: "New title")

    assert_equal initial_remark_count, publication.editorial_remarks.count
  end

  test "updating an edition updates the parent document timestamp" do
    edition = create(:edition)

    Timecop.travel 1.month do
      edition.update!(title: "Title updated")
      assert_equal edition.updated_at.to_i, edition.document.updated_at.to_i
    end
  end
end
