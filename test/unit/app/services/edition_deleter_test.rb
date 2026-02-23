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

  test "#perform! deletes associated offsite links" do
    published_edition = create(:published_standard_edition)
    offsite_link_1 = create(:offsite_link, url: "https://www.nhs.uk/", editions: [published_edition])
    offsite_link_2 = create(:offsite_link, url: "https://www.gov.uk/", editions: [published_edition])

    draft_edition = published_edition.create_draft(create(:writer))

    assert_equal [offsite_link_1, offsite_link_2], draft_edition.offsite_links, "Offsite links should be copied to the new draft edition"

    assert EditionDeleter.new(draft_edition).perform!
    assert_equal [offsite_link_1, offsite_link_2], published_edition.offsite_links.reload, "Offsite links associated with the published edition should not be deleted"
    assert_equal [], draft_edition.offsite_links.reload, "Offsite links should be unlinked from deleted draft"
  end
end
