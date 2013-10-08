require "test_helper"

class Edition::HasDocumentCollectionsTest < ActiveSupport::TestCase

  test "includes published document collection slugs in the search index data" do
    edition = create(:published_statistical_data_set)
    collection = create(:published_document_collection, :with_group)
    collection.groups.first.documents = [edition.document]
    assert_equal [collection.slug], edition.search_index["document_collections"]
  end

  test '#part_of_published_collection? returns true when its document is in a published collection' do
    edition = create(:published_publication)
    refute edition.part_of_published_collection?

    collection = create(:published_document_collection,
      groups: [build(:document_collection_group, documents: [edition.document])]
    )

    assert edition.reload.part_of_published_collection?
  end

  test '#part_of_published_collection? returns false when its document is in a draft collection' do
    edition = create(:published_publication)
    refute edition.part_of_published_collection?

    collection = create(:draft_document_collection,
      groups: [build(:document_collection_group, documents: [edition.document])]
    )

    refute edition.reload.part_of_published_collection?
  end

  test 'allows assignment of document collection on a saved edition' do
    edition = create(:imported_publication)
    document_collection = create(:document_collection, :with_group)
    edition.document_collection_group_ids = [document_collection.groups.first.id]
    assert_equal [document_collection], edition.document.document_collections
  end

  test 'raises an exception if attempt is made to set document collection on a new edition' do
    collection = create(:document_collection, :with_group)
    assert_raise(StandardError) do
      Publication.new(document_collection_group_ids: [collection.groups.first.id])
    end
  end
end
