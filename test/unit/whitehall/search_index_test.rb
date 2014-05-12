require 'test_helper'

module Whitehall
  class SearchIndexTest < ActiveSupport::TestCase
    class ::SearchableClass
    end

    test 'SearchIndex.add queues a search index add job for 10 seconds time to allow any transactions to complete' do
      searchable_thing = stub(class: SearchableClass, id: 'id')

      Sidekiq::Testing.fake! do
        SearchIndex.add(searchable_thing)
        job = SearchIndexAddWorker.jobs.last

        assert_equal ['SearchableClass', 'id'], job['args']
        assert_equal 10.seconds.from_now.to_i, job['at']
      end
    end

    test 'SearchIndex.delete queues a search index removal job for the instance based on its slug and rummager index' do
      searchable_thing = stub(search_index: { 'link' => 'full_slug' }, rummager_index: :index_name)

      Sidekiq::Testing.fake! do
        SearchIndex.delete(searchable_thing)
        job = SearchIndexDeleteWorker.jobs.last

        assert_equal ['full_slug', 'index_name'], job['args']
      end
    end
  end
end
