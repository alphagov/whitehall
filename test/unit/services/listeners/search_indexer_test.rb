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

  test '#index! with a policy re-indexes related editions' do
    policy = create(:published_policy)

    expect_indexing(policy)
    ReindexRelatedEditions.expects(:later).with(policy)
    ServiceListeners::SearchIndexer.new(policy).index!
  end

  test '#remove! removes the edition from the search index' do
    edition = create(:published_news_article)

    expect_removal_from_index(edition)
    ServiceListeners::SearchIndexer.new(edition).remove!
  end

  test '#remove! with a policy also re-indexes related editions' do
    policy = create(:published_policy)

    expect_removal_from_index(policy)
    ReindexRelatedEditions.expects(:later).with(policy)
    ServiceListeners::SearchIndexer.new(policy).remove!
  end

private

  def expect_indexing(*searchables)
    searchables.flatten.each { |searchable| Searchable::Index.expects(:later).with(searchable) }
  end

  def expect_removal_from_index(*searchables)
    searchables.flatten.each { |searchable| Searchable::Delete.expects(:later).with(searchable) }
  end
end
