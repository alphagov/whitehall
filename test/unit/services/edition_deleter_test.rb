require 'test_helper'

class EditionDeleterTest < ActiveSupport::TestCase
  test '#perform! with a draft edition deletes the edition' do
    edition = create(:draft_edition)

    assert EditionDeleter.new(edition).perform!
    assert edition.deleted?, 'Edition should be deleted'
  end

  test '#perform! with an imported edition deletes the edition' do
    edition = create(:imported_edition)

    assert EditionDeleter.new(edition).perform!
    assert edition.deleted?, 'Edition should be deleted'
  end

  test '#perform! with a submitted edition deletes the edition' do
    edition = create(:submitted_edition)

    assert EditionDeleter.new(edition).perform!
    assert edition.deleted?, 'Edition should be deleted'
  end

  test '#perform! with a rejected edition deletes the edition' do
    edition = create(:rejected_edition)

    assert EditionDeleter.new(edition).perform!
    assert edition.deleted?, 'Edition should be deleted'
  end

  test '#perform! with a published edition fails' do
    edition = create(:published_edition)

    refute EditionDeleter.new(edition).perform!
    assert edition.published?, 'Edition should still be published'
  end

  test '#perform! with an invalid edition deletes the edition' do
    edition = create(:draft_edition)
    edition.update_attribute(:title, '')

    assert EditionDeleter.new(edition).perform!
    assert edition.deleted?, 'Edition should be deleted'
  end

  test '#perform! changes the slug after deleting the edition' do
    edition = create(:draft_edition, title: 'Just A Test')

    assert EditionDeleter.new(edition).perform!
    edition.reload
    assert_equal 'deleted-just-a-test', edition.slug
  end

  test '#perform! soft-deletes any attachments that the edition has' do
    publication = create(:draft_publication)
    publication.attachments << attachment_1 = build(:file_attachment)
    publication.attachments << attachment_2 = build(:html_attachment)

    assert EditionDeleter.new(publication).perform!

    assert Attachment.find(attachment_1.id).deleted?
    assert Attachment.find(attachment_2.id).deleted?
  end
end
