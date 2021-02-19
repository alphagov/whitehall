require "test_helper"

class PublishingApiRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    task.reenable # without this, calling `invoke` does nothing after first test
  end

  describe "when fixing up a withdrawn document" do
    let(:task) { Rake::Task["publishing_api:bulk_republish:fix_withdrawn_documents"] }

    test "Tells Publishing API to remove draft edition for all locales" do
      unpublished_edition = create(
        :withdrawn_edition,
        translated_into: "fr",
      )

      Services.publishing_api.expects(:discard_draft).with(unpublished_edition.content_id, locale: "en").once
      Services.publishing_api.expects(:discard_draft).with(unpublished_edition.content_id, locale: "fr").once

      task.invoke
    end

    test "Fails gracefully if no draft exists (404 response)" do
      create(:withdrawn_edition)

      Services.publishing_api.expects(:discard_draft).raises(GdsApi::HTTPNotFound.new("No draft"))

      assert_nothing_raised do
        task.invoke
      end
    end

    test "Fails gracefully if no draft exists (422 response)" do
      create(:withdrawn_edition)

      Services.publishing_api.expects(:discard_draft).raises(GdsApi::HTTPUnprocessableEntity.new("No draft"))

      assert_nothing_raised do
        task.invoke
      end
    end

    test "Triggers PublishingApiUnpublishingWorker after removing draft" do
      unpublished_edition = create(:withdrawn_edition)
      operations = sequence("operations")

      Services.publishing_api.expects(:discard_draft).with(unpublished_edition.content_id, locale: "en")
        .once.in_sequence(operations)
      PublishingApiUnpublishingWorker.expects(:perform_async_in_queue)
        .with("bulk_republishing", unpublished_edition.unpublishing.id, false)
        .once.in_sequence(operations)

      task.invoke
    end

    test "Skips over withdrawn documents if they actually have a draft edition" do
      unpublished_edition = create(:withdrawn_edition)
      create(:draft_edition, document_id: unpublished_edition.document.id)

      Services.publishing_api.expects(:discard_draft).never
      PublishingApiUnpublishingWorker.expects(:perform_async_in_queue).never

      task.invoke
    end
  end
end
