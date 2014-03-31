require 'test_helper'

module Whitehall
  class SearchIndexTest < ActiveSupport::TestCase
    class ::SearchableClass
    end

    test 'SearchIndex.add queues a search index job for the instance' do
      searchable_thing = stub(class: SearchableClass, id: 'id')

      SearchIndexAddWorker.expects(:perform_async).with('SearchableClass', 'id')
      SearchIndex.add(searchable_thing)
    end

    test 'SearchIndex.delete queues a search index removal job for the instance' do
      searchable_thing = stub(search_index: { 'link' => 'full_slug' }, rummager_index: :index_name)

      SearchIndexDeleteWorker.expects(:perform_async).with('full_slug', :index_name)
      SearchIndex.delete(searchable_thing)
    end
  end
end
