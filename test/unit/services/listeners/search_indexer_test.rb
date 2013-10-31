require 'test_helper'

class ServiceListeners::SearchIndexerTest < ActiveSupport::TestCase
  test '#index! queues an Index job for the edition' do
    edition = create(:published_news_article)

    Searchable::Index.expects(:later).with(edition)
    ServiceListeners::SearchIndexer.new(edition).index!
  end

  test '#index! does nothing if edition cannot be indexed (i.e. non-english)' do
    non_english_edition = I18n.with_locale(:fr) { create(:world_location_news_article, :published, locale: :fr) }

    Searchable::Index.expects(:later).never
    ServiceListeners::SearchIndexer.new(non_english_edition).index!
  end


  test '#index! re-indexes policy supporting pages' do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    Searchable::Index.expects(:later).with(policy)
    Searchable::Index.expects(:later).with(supporting_page)

    ServiceListeners::SearchIndexer.new(policy).index!
  end

  test '#index! re-indexes a policies related editions' do
    policy = create(:published_policy)

    PolicySearchIndexObserver::ReindexRelatedEditions.expects(:later).with(policy)
    ServiceListeners::SearchIndexer.new(policy).index!
  end
end
