require "test_helper"

class DataHygiene::DeletedDocumentRestorerTest < ActiveSupport::TestCase
  test "it raises a document state error when the document's latest edition is not deleted" do
    published_edition = create(:published_edition)
    user = create(:user)
    restorer = DataHygiene::DeletedDocumentRestorer.new(published_edition.document.id, user.email)

    error = assert_raises DataHygiene::DeletedDocumentRestorer::RestoreDocumentError do
      restorer.run!
    end
    assert_equal error.message, "This document's latest edition is not deleted"
  end

  test "it raises a user not found error when there is no user found for the provided email address" do
    deleted_edition = create(:deleted_edition)
    email = "missing-user@example.com"

    restorer = DataHygiene::DeletedDocumentRestorer.new(deleted_edition.document.id, email)

    error = assert_raises DataHygiene::DeletedDocumentRestorer::RestoreDocumentError do
      restorer.run!
    end
    assert_equal error.message, "This document doesn't exist for user with email #{email}"
  end

  test "it creates a new draft of the deleted document with the provided user as the author" do
    deleted_edition = create(:deleted_edition)
    user = create(:user)

    restorer = DataHygiene::DeletedDocumentRestorer.new(deleted_edition.document.id, user.email)

    restorer.run!

    document = deleted_edition.document.reload
    assert document.latest_edition.draft?
    assert_equal document.latest_edition.creator, user
  end
end
