require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
  # re-using an existing table to make these tests much clearer
  # as all the searchable definition is in one place (and it doesn't
  # lend itself to redefinition)
  class SearchableTestTopic < ActiveRecord::Base
    self.table_name = 'classifications'

    include Searchable
    searchable  link: :name, only: :published, index_after: [:save], unindex_after: [:destroy]

    scope :published, -> { where(state: 'published') }
  end

  def setup
    Whitehall.stubs(:searchable_classes).returns([SearchableTestTopic])
  end

  test 'will not request indexing on save if it is not in searchable_instances' do
    s = SearchableTestTopic.new(name: 'woo', state: 'draft')
    Searchable::Index.expects(:later).never
    s.save
  end

  test 'will request indexing on save if it is in searchable_instances' do
    s = SearchableTestTopic.new(name: 'woo', state: 'published')
    Searchable::Index.expects(:later).with(s)
    s.save
  end

  test 'will request deletion on destruction even if it is not in searchable_instances' do
    s = SearchableTestTopic.create(name: 'woo', state: 'draft')
    Searchable::Delete.expects(:later).with(s)
    s.destroy
  end

  test 'will request deletion on destruction if it is contained in searchable_instances' do
    s = SearchableTestTopic.create(name: 'woo', state: 'published')
    Searchable::Delete.expects(:later).with(s)
    s.destroy
  end

  test 'will only request indexing of things that are included in the Whitehall.searchable_classes property' do
    class NonExistentClass; end
    Whitehall.stubs(:searchable_classes).returns([NonExistentClass])
    s = SearchableTestTopic.new(name: 'woo', state: 'published')
    Searchable::Index.expects(:later).never
    s.save
  end

  test '#reindex_all will not request indexing for an instance whose class is not in Whitehall.searchable_classes' do
    class NonExistentClass; end
    Whitehall.stubs(:searchable_classes).returns([NonExistentClass])
    s = SearchableTestTopic.create(name: 'woo', state: 'published')
    Searchable::Index.expects(:later).never
    SearchableTestTopic.reindex_all
  end

  test '#reindex_all will respect the scopes it is prefixed with' do
    s1 = SearchableTestTopic.create(name: 'woo', state: 'published')
    s2 = SearchableTestTopic.create(name: 'moo', state: 'published')
    Searchable::Index.expects(:later).with(s1).never
    Searchable::Index.expects(:later).with(s2)
    SearchableTestTopic.where(name: 'moo').reindex_all
  end

  test '#reindex_all will request indexing for each searchable instance' do
    s1 = SearchableTestTopic.create(name: 'woo', state: 'draft')
    s2 = SearchableTestTopic.create(name: 'woo', state: 'published')
    Searchable::Index.expects(:later).with(s1).never
    Searchable::Index.expects(:later).with(s2)
    SearchableTestTopic.reindex_all
  end

  test '#searchable_instances uses the searchable_options[:only] proc to find instances that can be searched' do
    draft_topic = SearchableTestTopic.create(name: 'woo', state: 'draft')
    published_topic = SearchableTestTopic.create(name: 'woo', state: 'published')

    searchable_topics = SearchableTestTopic.searchable_instances
    assert searchable_topics.include?(published_topic)
    refute searchable_topics.include?(draft_topic)
  end

  test 'Index.later will enqueue an indexing job with the class and id onto the rummager work queue' do
    s = SearchableTestTopic.create(name: 'woo', state: 'draft')
    Searchable::Index.expects(:new).with('SearchableTest::SearchableTestTopic', s.id).returns :an_indexing_job
    Delayed::Job.expects(:enqueue).with(:an_indexing_job, queue: Whitehall.rummager_work_queue_name)
    Searchable::Index.later(s)
  end

  test 'Delete.later will enqueue an indexing job with the link for the object and the index to remove it from onto the rummager work queue' do
    s = SearchableTestTopic.create(name: 'woo', state: 'draft')
    Searchable::Delete.expects(:new).with(s.name, :government).returns :a_deletion_job
    Delayed::Job.expects(:enqueue).with(:a_deletion_job, queue: Whitehall.rummager_work_queue_name)
    Searchable::Delete.later(s)
  end

  test 'Index#perform will raise if the supplied class name is not searchable' do
    class NonExistentClass; end
    Whitehall.stubs(:searchable_classes).returns([NonExistentClass])
    index_job = Searchable::Index.new('SearchableTest::SearchableTestTopic', 2_000)
    assert_raise(ArgumentError) { index_job.perform }
  end

  test 'Index#perform will raise if the supplied object does not exist' do
    index_job = Searchable::Index.new('SearchableTest::SearchableTestTopic', 2_000)
    assert_raise(ActiveRecord::RecordNotFound) { index_job.perform }
  end

  test 'Index#perform will not index the object if it is not in searchable_instances' do
    s = SearchableTestTopic.create(name: 'woo', state: 'draft')
    Whitehall::SearchIndex.indexer_class.any_instance.expects(:add_batch).never
    index_job = Searchable::Index.new(s.class.name, s.id)
    index_job.perform
  end

  test 'Index#perform will index the object if it is contained in searchable_instances' do
    s = SearchableTestTopic.create(name: 'woo', state: 'published')
    Whitehall::SearchIndex.indexer_class.any_instance.expects(:add_batch).once
    index_job = Searchable::Index.new(s.class.name, s.id)
    index_job.perform
  end

  test 'Delete#perform will remove the link from the index' do
    Whitehall::SearchIndex.indexer_class.any_instance.expects(:delete).with('woo').once
    delete_job = Searchable::Delete.new('woo', :government)
    delete_job.perform
  end

end
