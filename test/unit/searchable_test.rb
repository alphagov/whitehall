require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
  # re-using an existing table to make these tests much clearer
  # as all the searchable definition is in one place (and it doesn't
  # lend itself to redefinition)
  class SearchableTestTopic < ActiveRecord::Base
    self.table_name = 'classifications'
    include Searchable
    searchable(
      link: :name,
      only: :published,
      index_after: [:save],
      unindex_after: [:destroy]
    )
    scope :published, where(state: 'published')
  end

  def setup
    Whitehall.stubs(:searchable_classes).returns([SearchableTestTopic])
  end

  test 'will not add content to the search index if it is not contained in the scope described by the searchable[:only]' do
    s = SearchableTestTopic.new(name: 'woo', state: 'draft')
    Rummageable.expects(:index).never
    s.save
  end

  test 'will add content to the search index if it is contained in the scope described by the searchable[:only]' do
    s = SearchableTestTopic.new(name: 'woo', state: 'published')
    Rummageable.expects(:index).with(s.search_index, Whitehall.government_search_index_path).once
    s.save
  end

  test 'will remove content from the search index even if it is not contained in the scope described by the searchable[:only]' do
    s = SearchableTestTopic.create(name: 'woo', state: 'draft')
    Rummageable.expects(:delete).with('woo', Whitehall.government_search_index_path).once
    s.destroy
  end

  test 'will remove content from the search index if it is contained in the scope described by the searchable[:only]' do
    s = SearchableTestTopic.create(name: 'woo', state: 'published')
    Rummageable.expects(:delete).with('woo', Whitehall.government_search_index_path).once
    s.destroy
  end

  test 'will only index things that are included in the searchable_classes property' do
    class NonExistentClass; end
    Whitehall.stubs(:searchable_classes).returns([NonExistentClass])
    s = SearchableTestTopic.new(name: 'woo', state: 'published')
    Rummageable.expects(:index).never
    s.save
  end
end
