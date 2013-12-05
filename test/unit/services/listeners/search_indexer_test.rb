require 'test_helper'

class ServiceListeners::SearchIndexerTest < ActiveSupport::TestCase

  test '#index! queues an Index job for a published edition' do
    edition = create(:published_news_article)

    expect_indexing(edition)
    ServiceListeners::SearchIndexer.new(edition).index!
  end

  test '#index! does nothing if edition cannot be indexed (i.e. non-english)' do
    non_english_edition = I18n.with_locale(:fr) { create(:world_location_news_article, :published, locale: :fr) }

    Searchable::Index.expects(:later).never
    ServiceListeners::SearchIndexer.new(non_english_edition).index!
  end

  test '#index! also indexes all collection documents for collections' do
    publication = create(:published_publication)
    consultation = create(:published_consultation)
    collection = create(:published_document_collection, groups: [
      create(:document_collection_group, documents: [publication.document, consultation.document])
    ])

    expect_indexing(collection, publication, consultation)

    ServiceListeners::SearchIndexer.new(collection).index!
  end

  test '#remove! removes the edition from the search index' do
    edition = create(:published_news_article)

    expect_removal_from_index(edition)
    ServiceListeners::SearchIndexer.new(edition).remove!
  end

  test '#remove! also indexes all collection documents for collections' do
    publication = create(:published_publication)
    consultation = create(:published_consultation)
    collection = create(:published_document_collection, groups: [
      create(:document_collection_group, documents: [publication.document, consultation.document])
    ])

    expect_removal_from_index(collection)
    expect_indexing(publication, consultation)

    ServiceListeners::SearchIndexer.new(collection).remove!
  end

private

  def expect_indexing(*searchables)
    searchables.flatten.each { |searchable| Searchable::Index.expects(:later).with(searchable) }
  end

  def expect_removal_from_index(*searchables)
    searchables.flatten.each { |searchable| Searchable::Delete.expects(:later).with(searchable) }
  end
end
