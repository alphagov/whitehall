require "test_helper"
require "rake"

class ResluggingTest < ActiveSupport::TestCase
  setup do
    Rake::Task["reslug:document"].reenable
  end

  teardown do
    Sidekiq::Worker.clear_all
  end

  test "it should reslug a document" do
    document = create(:document, slug: "slugs-are-not-snails")
    edition = create(:published_publication, document: document)

    Whitehall::SearchIndex.expects(:delete).with(edition).returns(true)
    PublishingApiDocumentRepublishingWorker.any_instance.expects(:perform).with(document.id).returns(true)

    Rake.application.invoke_task "reslug:document[slugs-are-not-snails,snails-are-not-slugs]"

    assert_equal 0, Document.where(slug: "slugs-are-not-snails").count
    assert_equal 1, Document.where(slug: "snails-are-not-slugs").count
  end

  test "it should not reslug when there are multiple documents with the same slug" do
    document_one = create(:document, document_type: "StatisticalDataSet", slug: "a-slug-that-is-not-unique")
    document_two = create(:document, document_type: "Collection", slug: "a-slug-that-is-not-unique")

    create(:published_statistical_data_set, document: document_one)
    create(:published_document_collection, document: document_two)

    assert_raises do
      Rake.application.invoke_task "reslug:document[a-slug-that-is-not-unique,a-slug-that-wont-exist]"
    end

    assert_equal 2, Document.where(slug: "a-slug-that-is-not-unique").count
  end

  test "it should reslug the world location" do
    world_location_news = build(:world_location_news, content_id: SecureRandom.uuid)
    world_location = create(:world_location, slug: "old-name", world_location_news: world_location_news)
    Rake.application.invoke_task "reslug:world_location[old-name,new-name]"

    assert_equal "new-name", world_location.reload.slug
  end
end
