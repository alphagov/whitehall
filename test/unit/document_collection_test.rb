require "test_helper"

class DocumentCollectionTest < ActiveSupport::TestCase
  test 'should be invalid without a name' do
    collection = build(:document_collection, name: nil)
    refute collection.valid?
  end

  test 'should be associatable to editions' do
    collection = create(:document_collection)
    publication = create(:publication, document_collections: [collection])
    assert_equal [publication], collection.editions
  end

  test 'published_editions should return only those editions who are published' do
    collection = create(:document_collection)
    draft_publication = create(:draft_publication, document_collections: [collection])
    published_publication = create(:published_publication, document_collections: [collection])
    assert_equal [published_publication], collection.published_editions
  end

  test 'should not be destroyable if editions are associated' do
    collection = create(:document_collection)
    publication = create(:draft_publication, document_collections: [collection])
    collection.destroy
    assert DocumentCollection.find(collection.id)
  end
end
