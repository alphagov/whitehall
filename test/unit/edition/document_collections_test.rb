require "test_helper"

class Edition::DocumentCollectionsTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    collection = create(:document_collection)
    edition = create(:draft_publication, document_collections: [collection])
    relation = edition.edition_document_collections.first
    edition.destroy
    refute EditionDocumentCollection.find_by_id(relation.id)
  end
end
