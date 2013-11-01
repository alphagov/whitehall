require 'test_helper'

class ServiceListeners::SearchIndexerTest < ActiveSupport::TestCase

  test '#index! queues an Index job for a published edition' do
    edition = create(:published_news_article)

    expect_indexing(edition)
    ServiceListeners::SearchIndexer.new(edition).index!
  end

  test '#index! does nothing if edition cannot be indexed (i.e. non-english)' do
    non_english_edition = I18n.with_locale(:fr) { create(:world_location_news_article, :published, locale: :fr) }

    Searchable::Index.expects(:later).never
    ServiceListeners::SearchIndexer.new(non_english_edition).index!
  end

  test '#index! with a policy indexes supporting pages' do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, related_policies: [policy])

    expect_indexing(policy)
    expect_indexing(supporting_page)

    ServiceListeners::SearchIndexer.new(policy).index!
  end

  test "#index! with a republished policy removes the previous edition's supporting pages and indexes the latest ones" do
    old_version = create(:published_policy, supporting_pages: [create(:supporting_page), create(:supporting_page)])
    new_version = old_version.create_draft(create(:policy_writer)).reload
    new_version.minor_change = true
    force_publish(new_version)

    expect_indexing(new_version)
    expect_removal_from_index(old_version.supporting_pages.to_a)
    expect_indexing(new_version.supporting_pages.to_a)

    ServiceListeners::SearchIndexer.new(new_version).index!
  end

  test '#index! with a policy re-indexes related editions' do
    policy = create(:published_policy)

    expect_indexing(policy)
    ReindexRelatedEditions.expects(:later).with(policy)
    ServiceListeners::SearchIndexer.new(policy).index!
  end

  test '#remove! removes the edition from the search index' do
    edition = create(:published_news_article)

    expect_removal_from_index(edition)
    ServiceListeners::SearchIndexer.new(edition).remove!
  end

  test '#remove! with a policy also re-indexes related editions and removes supporting pages' do
    policy = create(:published_policy)

    expect_removal_from_index(policy)
    expect_removal_from_index(policy.supporting_pages.to_a)
    ReindexRelatedEditions.expects(:later).with(policy)
    ServiceListeners::SearchIndexer.new(policy).remove!
  end

private

  def expect_indexing(*searchables)
    searchables.flatten.each { |searchable| Searchable::Index.expects(:later).with(searchable) }
  end

  def expect_removal_from_index(*searchables)
    searchables.flatten.each { |searchable| Searchable::Delete.expects(:later).with(searchable) }
  end
end
