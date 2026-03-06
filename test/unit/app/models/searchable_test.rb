require "test_helper"

class SearchableTest < ActiveSupport::TestCase
  # re-using an existing table to make these tests much clearer
  # as all the searchable definition is in one place (and it doesn't
  # lend itself to redefinition)
  class SearchableTestTopic < ApplicationRecord
    self.table_name = "statistics_announcements"

    include Searchable
    searchable link: :title, only: :publicly_visible, index_after: [:save], unindex_after: [:destroy]

    scope :publicly_visible, -> { where(publishing_state: %w[published withdrawn]) }
  end

  def setup
    SearchApiPresenters.stubs(:searchable_classes).returns([SearchableTestTopic])
  end

  test "will not request indexing on save if it is not in searchable_instances" do
    searchable_test_topic = SearchableTestTopic.new(title: "woo", publishing_state: "draft", content_id: SecureRandom.uuid)
    Whitehall::SearchIndex.expects(:add).never
    searchable_test_topic.save!
  end

  test "will request indexing on save if it is in searchable_instances" do
    searchable_test_topic = SearchableTestTopic.create!(title: "woo", publishing_state: "published", content_id: SecureRandom.uuid)
    Whitehall::SearchIndex.expects(:add).with(searchable_test_topic)
    searchable_test_topic.save!
  end

  test "will request indexing on save if it is in searchable_instances and withrawn" do
    searchable_test_topic = SearchableTestTopic.create!(title: "woo", publishing_state: "withdrawn", content_id: SecureRandom.uuid)
    Whitehall::SearchIndex.expects(:add).with(searchable_test_topic)
    searchable_test_topic.save!
  end

  test "will request deletion on destruction even if it is not in searchable_instances" do
    searchable_test_topic = SearchableTestTopic.create!(title: "woo", publishing_state: "draft", content_id: SecureRandom.uuid)
    Whitehall::SearchIndex.expects(:delete).with(searchable_test_topic)
    searchable_test_topic.destroy!
  end

  test "will request deletion on destruction if it is contained in searchable_instances" do
    searchable_test_topic = SearchableTestTopic.create!(title: "woo", publishing_state: "published", content_id: SecureRandom.uuid)
    Whitehall::SearchIndex.expects(:delete).with(searchable_test_topic)
    searchable_test_topic.destroy!
  end

  test "will only request indexing of things that are included in the SearchApiPresenters.searchable_classes property" do
    non_existent_class = Class.new
    SearchApiPresenters.stubs(:searchable_classes).returns([non_existent_class])
    searchable_test_topic = SearchableTestTopic.new(title: "woo", publishing_state: "published", content_id: SecureRandom.uuid)
    Whitehall::SearchIndex.expects(:add).never
    searchable_test_topic.save!
  end

  test "#reindex_all will not request indexing for an instance whose class is not in SearchApiPresenters.searchable_classes" do
    non_existent_class = Class.new
    SearchApiPresenters.stubs(:searchable_classes).returns([non_existent_class])
    SearchableTestTopic.create!(title: "woo", publishing_state: "published", content_id: SecureRandom.uuid)
    Whitehall::SearchIndex.expects(:add).never
    SearchableTestTopic.reindex_all
  end

  test "#reindex_all will respect the scopes it is prefixed with" do
    searchable_test_topic1 = SearchableTestTopic.create!(title: "woo", publishing_state: "published", content_id: SecureRandom.uuid)
    searchable_test_topic2 = SearchableTestTopic.create!(title: "moo", publishing_state: "published", content_id: SecureRandom.uuid)
    Whitehall::SearchIndex.expects(:add).with(searchable_test_topic1).never
    Whitehall::SearchIndex.expects(:add).with(searchable_test_topic2)
    SearchableTestTopic.where(title: "moo").reindex_all
  end

  test "#reindex_all will request indexing for each searchable instance" do
    searchable_test_topic1 = SearchableTestTopic.create!(title: "woo", publishing_state: "draft", content_id: SecureRandom.uuid)
    searchable_test_topic2 = SearchableTestTopic.create!(title: "woo", publishing_state: "published", content_id: SecureRandom.uuid)
    Whitehall::SearchIndex.expects(:add).with(searchable_test_topic1).never
    Whitehall::SearchIndex.expects(:add).with(searchable_test_topic2)
    SearchableTestTopic.reindex_all
  end

  test "#searchable_instances uses the searchable_options[:only] proc to find instances that can be searched" do
    draft_topic = SearchableTestTopic.create!(title: "woo", publishing_state: "draft", content_id: SecureRandom.uuid)
    published_topic = SearchableTestTopic.create!(title: "woo", publishing_state: "published", content_id: SecureRandom.uuid)

    searchable_topics = SearchableTestTopic.searchable_instances
    assert searchable_topics.include?(published_topic)
    assert_not searchable_topics.include?(draft_topic)
  end
end
