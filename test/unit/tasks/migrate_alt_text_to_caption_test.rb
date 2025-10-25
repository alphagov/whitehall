require "test_helper"

class MigrateAltTextToCaptionTest < ActiveSupport::TestCase
  setup do
    @task = Rake::Task["data_migration:alt_text_to_caption"]
    @task.reenable
    Thor::Shell::Basic.any_instance.stubs(:yes?).returns(true)
  end

  test "migration task processes new images on subsequent runs" do
    edition1 = FactoryBot.create(:draft_publication)
    image1 = FactoryBot.create(:image, edition: edition1, alt_text: "Test alt text", caption: "")

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(image1.edition.document_id).once

    @task.invoke

    image1.reload
    assert_nil image1.alt_text, "Alt text should be cleared after first run"
    assert_equal "Test alt text", image1.caption

    image2 = FactoryBot.create(:image, edition: FactoryBot.create(:draft_publication), alt_text: "New image alt text", caption: "")

    image1.expects(:update_columns).never
    image1.expects(:update_column).never

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(image2.edition.document_id).once

    @task.reenable
    @task.invoke

    image1.reload
    image2.reload

    assert_nil image1.alt_text
    assert_equal "Test alt text", image1.caption

    assert_nil image2.alt_text, "New image alt text should be cleared"
    assert_equal "New image alt text", image2.caption
  end

  test "migration task only processes images with alt text" do
    edition1 = FactoryBot.create(:draft_publication)
    edition2 = FactoryBot.create(:draft_publication)
    edition3 = FactoryBot.create(:draft_publication)

    image_without_alt = FactoryBot.create(:image, edition: edition1, alt_text: nil, caption: "Keep this")
    image_with_empty_alt = FactoryBot.create(:image, edition: edition2, alt_text: "", caption: "Keep this too")
    image_with_alt = FactoryBot.create(:image, edition: edition3, alt_text: "Process this", caption: "")

    image_without_alt.expects(:update_columns).never
    image_without_alt.expects(:update_column).never
    image_with_empty_alt.expects(:update_columns).never
    image_with_empty_alt.expects(:update_column).never

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(image_with_alt.edition.document_id).once

    @task.invoke

    image_without_alt.reload
    image_with_empty_alt.reload
    image_with_alt.reload

    assert_nil image_without_alt.alt_text
    assert_equal "Keep this", image_without_alt.caption

    assert_equal "", image_with_empty_alt.alt_text
    assert_equal "Keep this too", image_with_empty_alt.caption

    assert_nil image_with_alt.alt_text, "Alt text should be cleared"
    assert_equal "Process this", image_with_alt.caption
  end

  test "empty alt text keeps existing caption" do
    edition = FactoryBot.create(:draft_publication)
    image = FactoryBot.create(:image, edition: edition, alt_text: "", caption: "Original caption")

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).never

    @task.invoke

    image.reload
    assert_equal "", image.alt_text, "Empty alt text should remain unchanged"
    assert_equal "Original caption", image.caption, "Caption should be preserved"
  end

  test "identical content avoids duplication" do
    edition = FactoryBot.create(:draft_publication)
    image = FactoryBot.create(:image, edition: edition, alt_text: "Same text", caption: "Same text")

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).never

    @task.invoke

    image.reload
    assert_nil image.alt_text, "Alt text should be cleared"
    assert_equal "Same text", image.caption, "Caption should remain the same"
  end

  test "credit terms combined with descriptive alt text over minimum length" do
    edition = FactoryBot.create(:draft_publication)
    image = FactoryBot.create(:image,
                              edition: edition,
                              alt_text: "Long descriptive alternative text",
                              caption: "Credit: Photographer Name")

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(image.edition.document_id).once

    @task.invoke

    image.reload
    assert_nil image.alt_text, "Alt text should be cleared"
    assert_equal "Long descriptive alternative text [Credit: Photographer Name]", image.caption
  end

  test "credit terms not combined with short alt text" do
    min_length_alt = "a" * ALT_TEXT_MIGRATION_DESCRIPTIVE_MIN_LENGTH
    edition = FactoryBot.create(:draft_publication)
    image = FactoryBot.create(:image,
                              edition: edition,
                              alt_text: min_length_alt,
                              caption: "Credit: Test Photography")

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).never

    @task.invoke

    image.reload
    assert_nil image.alt_text, "Alt text should be cleared"
    assert_equal "Credit: Test Photography", image.caption, "Should use longer caption when alt text is at minimum length"
  end

  test "uses longer text when no credit terms present" do
    edition = FactoryBot.create(:draft_publication)
    image = FactoryBot.create(:image,
                              edition: edition,
                              alt_text: "Short alt",
                              caption: "Much longer caption text here")

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).never

    @task.invoke

    image.reload
    assert_nil image.alt_text, "Alt text should be cleared"
    assert_equal "Much longer caption text here", image.caption
  end

  test "uses alt text when caption is empty" do
    edition = FactoryBot.create(:draft_publication)
    image = FactoryBot.create(:image, edition: edition, alt_text: "Alt text content", caption: "")

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(image.edition.document_id).once

    @task.invoke

    image.reload
    assert_nil image.alt_text, "Alt text should be cleared"
    assert_equal "Alt text content", image.caption
  end

  test "task includes dry run preview and requires confirmation" do
    edition = FactoryBot.create(:draft_publication, title: "Test Publication")
    image = FactoryBot.create(:image, edition: edition, alt_text: "Test alt text", caption: "")

    Thor::Shell::Basic.any_instance.stubs(:yes?).returns(false)

    output = capture_io do
      @task.invoke
    end

    image.reload
    assert_equal "Test alt text", image.alt_text, "Alt text should remain unchanged when migration is aborted"
    assert_equal "", image.caption, "Caption should remain unchanged when migration is aborted"

    assert_includes output[0], "DRY RUN PREVIEW", "Should show dry run preview"
    assert_includes output[0], "Migration aborted by user", "Should show abort message"
  end

  test "task proceeds with migration when confirmed" do
    edition = FactoryBot.create(:draft_publication, title: "Test Publication")
    image = FactoryBot.create(:image, edition: edition, alt_text: "Test alt text", caption: "")

    Thor::Shell::Basic.any_instance.stubs(:yes?).returns(true)

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(image.edition.document_id).once

    output = capture_io do
      @task.invoke
    end

    image.reload
    assert_nil image.alt_text, "Alt text should be cleared after migration"
    assert_equal "Test alt text", image.caption, "Caption should be updated"

    assert_includes output[0], "DRY RUN PREVIEW", "Should show dry run preview"
    assert_includes output[0], "RUNNING MIGRATION", "Should show migration execution"
    assert_includes output[0], "Migration complete!", "Should show completion message"
  end

  test "republishes document when caption changes" do
    edition = FactoryBot.create(:draft_publication)
    image = FactoryBot.create(:image, edition: edition, alt_text: "New caption content", caption: "")

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(edition.document_id).once

    @task.invoke

    image.reload
    assert_nil image.alt_text, "Alt text should be cleared"
    assert_equal "New caption content", image.caption
  end

  test "does not republish document when caption unchanged" do
    edition = FactoryBot.create(:draft_publication)
    image = FactoryBot.create(:image, edition: edition, alt_text: "Same content", caption: "Same content")

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).never

    @task.invoke

    image.reload
    assert_nil image.alt_text, "Alt text should be cleared"
    assert_equal "Same content", image.caption
  end
end
