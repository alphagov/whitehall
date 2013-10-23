require 'test_helper'

class Edition::SearchIndexerTest < ActiveSupport::TestCase

  test '#edition_published queues an Index job for the edition' do
    edition = create(:published_news_article)
    Searchable::Index.expects(:later).with(edition)

    Edition::SearchIndexer.edition_published(edition)
  end

  test '#edition_published does nothing if edition cannot be indexed (i.e. non-english)' do
    non_english_edition = I18n.with_locale(:fr) { create(:world_location_news_article, :published, locale: :fr) }

    Searchable::Index.expects(:later).never
    Edition::SearchIndexer.edition_published(non_english_edition)
  end


  test '#edition_published re-indexes policy supporting pages' do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    Searchable::Index.expects(:later).with(policy)
    Searchable::Index.expects(:later).with(supporting_page)

    Edition::SearchIndexer.edition_published(policy)
  end
end
