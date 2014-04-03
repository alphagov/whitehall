require 'test_helper'

class SearchIndexDeleteWorkerTest < ActiveSupport::TestCase

  test '#perform deletes the instance from its index' do
    index = mock('search_index')
    index.expects(:delete).with('woo')
    Whitehall::SearchIndex.expects(:for).with(:government).returns(index)

    SearchIndexDeleteWorker.new.perform('woo', 'government')
  end
end
