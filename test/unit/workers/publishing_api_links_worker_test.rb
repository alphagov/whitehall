require 'test_helper'

class PublishingApiLinksWorkerTest < ActiveSupport::TestCase
  test "raises an error if an edition's document is locked" do
    edition = create(:unpublished_edition, :with_locked_document)
    assert_raises LockedDocumentConcern::LockedDocumentError, "Cannot perform this operation on a locked document" do
      PublishingApiLinksWorker.new.perform(edition.id)
    end
  end
end
