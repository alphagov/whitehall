require "test_helper"

class Edition::HasDocumentCollectionsTest < ActiveSupport::TestCase

  test "includes document collection slugs in the search index data" do
    edition = create(:published_statistical_data_set)
    collection = create(:document_collection, :with_group)
    collection.groups.first.documents = [edition.document]
    assert_equal [collection.slug], edition.search_index["document_collection"]
  end

  test '#part_of_collection? returns true when its document is in a collection' do
    edition = create(:published_publication)
    refute edition.part_of_collection?

    collection = create(:document_collection, :with_group)
    collection.groups.first.documents = [edition.document]
    assert edition.reload.part_of_collection?
  end

  test 'allows assignment of document collection on a saved edition' do
    edition = create(:imported_publication)
    document_collection = create(:document_collection, :with_group)
    edition.document_collection_group_ids = [document_collection.groups.first.id]
    assert_equal [document_collection], edition.document.document_collection
  end

  test 'raises an exception if attempt is made to set document collection on a new edition' do
    collection = create(:document_collection, :with_group)
    assert_raise(StandardError) do
      Publication.new(document_collection_group_ids: [collection.groups.first.id])
    end
  end
end
