require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
  # re-using an existing table to make these tests much clearer
  # as all the searchable definition is in one place (and it doesn't
  # lend itself to redefinition)
  class SearchableTestTopic < ApplicationRecord
    self.table_name = 'classifications'

    include Searchable
    searchable link: :name, only: :publicly_visible, index_after: [:save], unindex_after: [:destroy]

    scope :publicly_visible, -> { where(state: %w(published withdrawn)) }
  end

  def setup
    RummagerPresenters.stubs(:searchable_classes).returns([SearchableTestTopic])
  end

  test 'will not request indexing on save if it is not in searchable_instances' do
    s = SearchableTestTopic.new(name: 'woo', state: 'draft')
    Whitehall::SearchIndex.expects(:add).never
    s.save
  end

  test 'will request indexing on save if it is in searchable_instances' do
    s = SearchableTestTopic.create(name: 'woo', state: 'published')
    Whitehall::SearchIndex.expects(:add).with(s)
    s.save
  end

  test 'will request indexing on save if it is in searchable_instances and withrawn' do
    s = SearchableTestTopic.create(name: 'woo', state: 'withdrawn')
    Whitehall::SearchIndex.expects(:add).with(s)
    s.save
  end

  test 'will request deletion on destruction even if it is not in searchable_instances' do
    s = SearchableTestTopic.create(name: 'woo', state: 'draft')
    Whitehall::SearchIndex.expects(:delete).with(s)
    s.destroy
  end

  test 'will request deletion on destruction if it is contained in searchable_instances' do
    s = SearchableTestTopic.create(name: 'woo', state: 'published')
    Whitehall::SearchIndex.expects(:delete).with(s)
    s.destroy
  end

  test 'will only request indexing of things that are included in the RummagerPresenters.searchable_classes property' do
    class NonExistentClass; end
    RummagerPresenters.stubs(:searchable_classes).returns([NonExistentClass])
    s = SearchableTestTopic.new(name: 'woo', state: 'published')
    Whitehall::SearchIndex.expects(:add).never
    s.save
  end

  test '#reindex_all will not request indexing for an instance whose class is not in RummagerPresenters.searchable_classes' do
    class NonExistentClass; end
    RummagerPresenters.stubs(:searchable_classes).returns([NonExistentClass])
    SearchableTestTopic.create(name: 'woo', state: 'published')
    Whitehall::SearchIndex.expects(:add).never
    SearchableTestTopic.reindex_all
  end

  test '#reindex_all will respect the scopes it is prefixed with' do
    s1 = SearchableTestTopic.create(name: 'woo', state: 'published')
    s2 = SearchableTestTopic.create(name: 'moo', state: 'published')
    Whitehall::SearchIndex.expects(:add).with(s1).never
    Whitehall::SearchIndex.expects(:add).with(s2)
    SearchableTestTopic.where(name: 'moo').reindex_all
  end

  test '#reindex_all will request indexing for each searchable instance' do
    s1 = SearchableTestTopic.create(name: 'woo', state: 'draft')
    s2 = SearchableTestTopic.create(name: 'woo', state: 'published')
    Whitehall::SearchIndex.expects(:add).with(s1).never
    Whitehall::SearchIndex.expects(:add).with(s2)
    SearchableTestTopic.reindex_all
  end

  test '#searchable_instances uses the searchable_options[:only] proc to find instances that can be searched' do
    draft_topic = SearchableTestTopic.create(name: 'woo', state: 'draft')
    published_topic = SearchableTestTopic.create(name: 'woo', state: 'published')

    searchable_topics = SearchableTestTopic.searchable_instances
    assert searchable_topics.include?(published_topic)
    refute searchable_topics.include?(draft_topic)
  end
end
