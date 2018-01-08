require 'test_helper'

class SearchIndexAddWorkerTest < ActiveSupport::TestCase
  test '#perform raises an exception if the class is not searchable' do
    class NonSearchableClass; end

    worker = SearchIndexAddWorker.new
    e = assert_raise(ArgumentError) { worker.perform('NonSearchableClass', 1) }
    assert_match /is not a searchable class/, e.message
  end

  test '#perform logs a warning if the instance does not exist' do
    Rails.logger.expects(:warn).once
    SearchIndexAddWorker.new.perform('Topic', 1)
  end

  test '#perform indexes searchable instances' do
    published_publication = create(:published_publication)
    attributes_for_indexing_mock = mock

    Publication.any_instance.stubs(:search_index).returns(attributes_for_indexing_mock)
    Whitehall::SearchIndex.indexer_class.any_instance.expects(:add).with(attributes_for_indexing_mock)
    SearchIndexAddWorker.new.perform(published_publication.class.name, published_publication.id)
  end

  test '#perform does not index non-searchable instances and logs a warning' do
    draft_publication = create(:draft_publication)

    Whitehall::SearchIndex.indexer_class.any_instance.expects(:add).never
    Rails.logger.expects(:warn).once
    SearchIndexAddWorker.new.perform(draft_publication.class.name, draft_publication.id)
  end
end
