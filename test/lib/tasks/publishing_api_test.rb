require "test_helper"

class PublishingApiRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    task.reenable # without this, calling `invoke` does nothing after first test
  end

  describe "republishing all documents of a given organisation" do
    let(:org) { create(:organisation) }
    let(:task) { Rake::Task["publishing_api:bulk_republish:for_organisation"] }

    test "Republishes the latest edition for each document owned by the organisation" do
      edition = create(:published_news_article, organisations: [org])

      PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
        "bulk_republishing",
        edition.document.id,
        true,
      ).once

      task.invoke(org.slug)
    end

    test "Ignores documents owned by other organisation" do
      some_other_org = create(:organisation)
      edition = create(:published_news_article, organisations: [some_other_org])

      PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
        "bulk_republishing",
        edition.document.id,
        true,
      ).never

      task.invoke(org.slug)
    end
  end
end
