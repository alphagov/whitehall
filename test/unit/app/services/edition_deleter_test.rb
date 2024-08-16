require "test_helper"

class EditionDeleterTest < ActiveSupport::TestCase
  test "#perform! with a draft edition deletes the edition" do
    edition = create(:draft_edition)

    assert EditionDeleter.new(edition).perform!
    assert edition.deleted?, "Edition should be deleted"
  end

  test "#perform! with a submitted edition deletes the edition" do
    edition = create(:submitted_edition)

    assert EditionDeleter.new(edition).perform!
    assert edition.deleted?, "Edition should be deleted"
  end

  test "#perform! with a rejected edition deletes the edition" do
    edition = create(:rejected_edition)

    assert EditionDeleter.new(edition).perform!
    assert edition.deleted?, "Edition should be deleted"
  end

  test "#perform! with a published edition fails" do
    edition = create(:published_edition)

    assert_not EditionDeleter.new(edition).perform!
    assert edition.published?, "Edition should still be published"
  end

  test "#perform! with an invalid edition deletes the edition" do
    edition = create(:draft_edition)
    edition.title = ""
    edition.save!(validate: false)

    assert EditionDeleter.new(edition).perform!
    assert edition.deleted?, "Edition should be deleted"
  end

  test "#perform! changes the slug after deleting the edition" do
    edition = create(:draft_edition, title: "Just A Test")

    assert EditionDeleter.new(edition).perform!
    edition.reload
    assert_equal "deleted-just-a-test", edition.slug
  end

  test "#perform! soft-deletes any attachments that the edition has" do
    publication = create(:draft_publication)
    publication.attachments << attachment1 = build(:file_attachment)
    publication.attachments << attachment2 = build(:html_attachment)

    assert EditionDeleter.new(publication).perform!

    assert Attachment.find(attachment1.id).deleted?
    assert Attachment.find(attachment2.id).deleted?
  end

  test "#perform! deletes associated edition roles" do
    roles = create_list(:role, 2)
    edition = create(:draft_worldwide_organisation, roles:)

    assert EditionDeleter.new(edition).perform!
    edition.reload
    assert edition.roles.empty?
  end
end
