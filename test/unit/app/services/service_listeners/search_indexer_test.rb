require "test_helper"

class ServiceListeners::SearchIndexerTest < ActiveSupport::TestCase
  test "#index! indexes published edition" do
    edition = create(:published_news_article)

    expect_indexing(edition)
    ServiceListeners::SearchIndexer.new(edition).index!
  end

  test "#index! does nothing if edition cannot be indexed (i.e. non-english)" do
    non_english_edition = I18n.with_locale(:fr) do
      create(:news_article_world_news_story, :published, primary_locale: :fr)
    end

    Whitehall::SearchIndex.expects(:add).never
    ServiceListeners::SearchIndexer.new(non_english_edition).index!
  end

  test "#index! also indexes all collection documents for collections" do
    publication = create(:published_publication)
    consultation = create(:published_consultation)
    collection = create(
      :published_document_collection,
      groups: [
        create(:document_collection_group, documents: [publication.document, consultation.document]),
      ],
    )

    expect_indexing(collection, publication, consultation)

    ServiceListeners::SearchIndexer.new(collection).index!
  end

  test "#index! removes the edition first if the publication type has changed" do
    published_publication = create(:published_policy_paper)
    edition = create(:published_national_statistics, document: published_publication.document)

    expect_removal_from_index(published_publication)
    expect_indexing(edition)
    ServiceListeners::SearchIndexer.new(edition).index!
  end

  test "#index! removes the edition from the search index if the current edition cannot be indexed, but the previous edition was indexed" do
    english_edition = create(:news_article_world_news_story, :published)
    ServiceListeners::SearchIndexer.new(english_edition).index!
    non_english_edition = I18n.with_locale(:fr) do
      create(:news_article_world_news_story, :published, primary_locale: :fr, document: english_edition.document)
    end

    expect_removal_from_index(english_edition)
    ServiceListeners::SearchIndexer.new(non_english_edition).index!
  end

  test "#remove! removes the edition from the search index" do
    edition = create(:published_news_article)

    expect_removal_from_index(edition)
    ServiceListeners::SearchIndexer.new(edition).remove!
  end

  test "#remove! also indexes all collection documents for collections" do
    publication = create(:published_publication)
    consultation = create(:published_consultation)
    collection = create(
      :published_document_collection,
      groups: [
        create(:document_collection_group, documents: [publication.document, consultation.document]),
      ],
    )

    expect_removal_from_index(collection)
    expect_indexing(publication, consultation)

    ServiceListeners::SearchIndexer.new(collection).remove!
  end

private

  def expect_indexing(*searchables)
    searchables.flatten.each { |searchable| Whitehall::SearchIndex.expects(:add).with(searchable) }
  end

  def expect_removal_from_index(*searchables)
    searchables.flatten.each { |searchable| Whitehall::SearchIndex.expects(:delete).with(searchable) }
  end
end
