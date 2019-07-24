require 'test_helper'

class PublishingApiLinksWorkerTest < ActiveSupport::TestCase
  test "raises an error if an edition's document is locked" do
    document = create(:document, locked: true)
    edition = create(:edition, document: document)

    assert_raises RuntimeError, "Cannot send a locked document to the Publishing API" do
      PublishingApiLinksWorker.new.perform(edition.id)
    end
  end
end
