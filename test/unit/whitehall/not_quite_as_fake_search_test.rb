require "fast_test_helper"
require "whitehall/not_quite_as_fake_search"

module Whitehall
  module NotQuiteAsFakeSearch
    class Test < ActiveSupport::TestCase
      setup do
        @store = Store.new
        SearchIndex.indexer_class.store = @store
        @index = SearchIndex.indexer_class.new('http://rummager.test', 'government')
      end

      teardown do
        SearchIndex.indexer_class.store = nil
      end

      test "a document is present in the store after adding to Rummageable" do
        @index.add({ 'link' => '/foo', 'title' => 'Foo' })
        expected_index = { '/foo' => { 'link' => '/foo', 'title' => 'Foo' } }
        assert_equal expected_index, @store.index('government')
      end

      test "date fields are converted to strings when fetched from the store" do
        @index.add({ 'my_date' => Time.zone.parse("2013-01-01 12:13 +00:00"), 'link' => '/example' })
        expected_index = { '/example' => { 'link' => '/example', 'my_date' => '2013-01-01 12:13:00 +0000' } }
        assert_equal expected_index, @store.index('government')
      end

      test "a document can be retrieved by advanced search" do
        @index.add({ 'link' => '/foo', 'title' => 'Foo' })
        client = GdsApiRummager.new('government', @store)
        actual_results = client.advanced_search(per_page: "10", page: "1", keywords: "Foo")
        expected_results = {
          'total' => 1,
          'results' => [{ 'link' => '/foo', 'title' => 'Foo' }]
        }
        assert_equal expected_results, actual_results
      end

      test "advanced search finds documents with the requested keywords in the title" do
        @index.add_batch(build_documents(*%w{Foo Bar}))
        assert_search_returns_documents %w{Bar}, keywords: "Bar"
      end

      test "advanced search finds documents with the requested keywords in the description" do
        @index.add_batch(build_documents(*%w{Foo Bar}))
        assert_search_returns_documents %w{Bar}, keywords: "Bar-description"
      end

      test "advanced search finds documents with the requested keywords in the indexable content" do
        @index.add_batch(build_documents(*%w{Foo Bar}))
        assert_search_returns_documents %w{Bar}, keywords: "Bar-indexable_content"
      end

      test "advanced search can select documents with a field matching a list of values" do
        @index.add_batch(build_documents(*%w{Foo Bar}))
        assert_search_returns_documents %w{Bar}, topics: ["Bar-topic1"]
      end

      test "advanced search can select documents with a field matching any item from a list of values" do
        @index.add_batch(build_documents(*%w{Foo Bar FooBar}))
        assert_search_returns_documents %w{Foo Bar}, topics: ["Foo-topic2", "Bar-topic1"]
      end

      test "advanced search can select documents with a field matching a single value" do
        @index.add_batch(build_documents(*%w{Foo Bar}))
        assert_search_returns_documents %w{Bar}, topics: "Bar-topic1"
      end

      test "advanced search for a field which is not present in a document does not return the document" do
        documents = build_documents(*%w{Foo Bar})
        documents[0]['world_locations'] = ["Hawaii"]
        @index.add_batch(documents)
        assert_search_returns_documents %w{Foo}, world_locations: "Hawaii"
      end

      test "advanced search can select documents using a boolean filter" do
        documents = build_documents(*%w{Foo Bar})
        documents[0]['relevant_to_local_government'] = true
        @index.add_batch(documents)
        assert_search_returns_documents %w{Foo}, relevant_to_local_government: "true"
        assert_search_returns_documents %w{Foo}, relevant_to_local_government: "1"
        assert_search_returns_documents %w{Bar}, relevant_to_local_government: "false"
        assert_search_returns_documents %w{Bar}, relevant_to_local_government: "0"
      end

      test "advanced search raises if boolean filter is not a boolean-ish value" do
        assert_invalid_search(relevant_to_local_government: "hello")
        assert_invalid_search(relevant_to_local_government: "")
        assert_invalid_search(relevant_to_local_government: "yes")
        assert_invalid_search(relevant_to_local_government: "no")
        assert_invalid_search(relevant_to_local_government: "false evidence")
        assert_invalid_search(relevant_to_local_government: "true facts")
      end

      test "advanced search raises if date filter is not a pure date" do
        assert_invalid_search(public_timestamp: {before: "2013-01-31 00:00:00"})
      end

      test "advanced search can select documents using a date filter" do
        documents = build_documents(*%w{Foo Bar Qux})
        documents[0]['public_timestamp'] = Time.zone.parse("2011-01-01 01:01:01")
        documents[1]['public_timestamp'] = Time.zone.parse("2011-02-02 02:02:02")
        documents[2]['public_timestamp'] = Time.zone.parse("2011-03-03 02:02:02")
        @index.add_batch(documents)
        assert_search_returns_documents %w{Foo}, public_timestamp: {to: "2011-01-31"}
        assert_search_returns_documents %w{Qux Bar}, public_timestamp: {from: "2011-01-31"}
        assert_search_returns_documents %w{Bar}, public_timestamp: {from: "2011-01-31", to: "2011-02-28"}
      end

      test "advanced search can order documents explicitly" do
        documents = build_documents(*%w{Foo Bar Qux})
        documents[0]['public_timestamp'] = Time.zone.parse("2011-01-01 01:01:01")
        documents[1]['public_timestamp'] = Time.zone.parse("2011-03-03 02:02:02")
        documents[2]['public_timestamp'] = Time.zone.parse("2011-01-01 01:01:01")
        @index.add_batch(documents)
        assert_search_returns_documents %w{Bar Foo Qux}, order: {title: "asc"}
        assert_search_returns_documents %w{Qux Foo Bar}, order: {title: "desc"}
        assert_search_returns_documents %w{Foo Qux Bar}, order: {public_timestamp: "asc", title: "asc"}
      end

      test "advanced search raises if order direction is not asc or desc" do
        assert_invalid_search(order: {title: 'up'})
        assert_invalid_search(order: {title: 'down'})
        assert_invalid_search(order: {title: 'description'})
        assert_invalid_search(order: {public_timestamp: 'asc', title: 'description'})
      end

      test "advanced search can be paginated" do
        documents = build_documents(*(1.upto(20).map {|n| "doc-#{n}"}))
        @index.add_batch(documents)
        assert_search_returns_documents %w{doc-1 doc-2 doc-3}, page: 1, per_page: 3
        assert_search_returns_documents %w{doc-4 doc-5 doc-6}, page: 2, per_page: 3
        assert_search_returns_documents %w{doc-19 doc-20}, page: 7, per_page: 3
        assert_search_total 20, page: 1, per_page: 3
      end

      test "advanced search allows filtering by any known param" do
        not_quite_as_fake_rummager = GdsApiRummager.new("government", @store, simple: %w{title})
        results = not_quite_as_fake_rummager.advanced_search(default_search_params.merge(title: "something"))
        assert_equal [], results["results"]
      end

      test "advanced search raises if attempting to filter by an unknown param" do
        not_quite_as_fake_rummager = GdsApiRummager.new("government", @store, simple: %w{title})
        assert_raise GdsApi::Rummager::SearchServiceError do
          not_quite_as_fake_rummager.advanced_search(default_search_params.merge(topic: "something"))
        end
      end

      def assert_search_returns_documents(expected_document_titles, search_params)
        actual_results = GdsApiRummager.new("government", @store).advanced_search(default_search_params.merge(search_params))
        assert_equal expected_document_titles, actual_results["results"].map {|r| r['title']}
      end

      def assert_search_total(expected_total, search_params)
        actual_results = GdsApiRummager.new("government", @store).advanced_search(default_search_params.merge(search_params))
        assert_equal expected_total, actual_results["total"]
      end

      def assert_invalid_search(search_params)
        assert_raise GdsApi::Rummager::SearchServiceError do
          GdsApiRummager.new("government", @store).advanced_search(default_search_params.merge(search_params))
        end
      end

      def default_search_params
        {per_page: "10", page: "1"}
      end

      def build_documents(*titles)
        titles.map do |title|
          {
            "link" => "/#{title}",
            "title" => title,
            "description" => "#{title}-description",
            "indexable_content" => "#{title}-indexable_content",
            topics: ["#{title}-topic1", "#{title}-topic2"],
            "relevant_to_local_government" => false,
            "public_timestamp" => Time.zone.parse("2011-01-01 00:00:00")
          }
        end
      end
    end
  end
end
