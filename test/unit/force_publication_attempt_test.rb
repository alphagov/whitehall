require "test_helper"

class ForcePublicationAttemptTest < ActiveSupport::TestCase
  setup do
    @gds_team = create(:gds_editor, name: "GDS Inside Government Team")
  end

  test "reports the start time and total number of documents to be force published" do
    stubbed_import = stub_import([build(:imported_edition), build(:imported_edition)])
    force_publish_attempt = ForcePublicationAttempt.create
    force_publish_attempt.stubs(:import).returns(stubbed_import)
    ForcePublisher::Worker.any_instance.stubs(:force_publish!)

    force_publish_attempt.perform

    assert_equal 2, force_publish_attempt.total_documents
    assert_equal Time.zone.now, force_publish_attempt.started_at
  end

  test "failed publishings are reported" do
    stubbed_import = stub_import([unpublishable_edition])

    force_publish_attempt = ForcePublicationAttempt.create
    force_publish_attempt.stubs(import: stubbed_import)

    force_publish_attempt.perform
    assert_equal 0, force_publish_attempt.successful_documents
    assert_equal 1, force_publish_attempt.failed_documents
    assert force_publish_attempt.successes.empty?
  end

  test "publishing failure reasons are logged" do
    stubbed_import = stub_import([unpublishable_edition])

    force_publish_attempt = ForcePublicationAttempt.create
    force_publish_attempt.stubs(:import).returns stubbed_import

    force_publish_attempt.progress_logger.expects(:failure).with(unpublishable_edition, "This edition is invalid: Title can't be blank")

    force_publish_attempt.perform
  end

  test "exceptions raised during publication are caught and logged" do
    exceptional_edition = publishable_edition
    exception = ArgumentError.new('eek!')
    exceptional_edition.stubs(:force_publish!).raises(exception)

    stubbed_import = stub_import([exceptional_edition])
    force_publish_attempt = ForcePublicationAttempt.create
    force_publish_attempt.stubs(:import).returns stubbed_import

    force_publish_attempt.progress_logger.expects(:failure).with(exceptional_edition, exception)

    force_publish_attempt.perform
  end

  test "force publishable editions are force published and logged as a success" do
    stub_panopticon_registration(publishable_edition)
    stubbed_import = stub_import([publishable_edition])
    force_publish_attempt = ForcePublicationAttempt.create
    force_publish_attempt.stubs(:import).returns stubbed_import

    force_publish_attempt.progress_logger.expects(:success).with(publishable_edition)
    force_publish_attempt.perform

    assert publishable_edition.reload.published?
  end

  test "reports the finish time and total number of documents successfully published" do
    stub_panopticon_registration(publishable_edition)
    stubbed_import = stub_import([publishable_edition, unpublishable_edition])
    force_publish_attempt = ForcePublicationAttempt.create
    force_publish_attempt.stubs(:import).returns stubbed_import

    Timecop.freeze(1.day.from_now) do
      force_publish_attempt.perform

      assert_equal 1, force_publish_attempt.successful_documents
      assert_equal 1, force_publish_attempt.failed_documents
      assert_equal Time.zone.now, force_publish_attempt.finished_at
    end
  end

private

  def stub_import(force_publishable_editions)
    stub(:import).tap do |stubbed_import|
      stubbed_import.stubs(:force_publishable_editions).returns(force_publishable_editions)
      stubbed_import.stubs(:force_publishable_edition_count).returns(force_publishable_editions.size)
    end
  end

  def publishable_edition
    @publishable_edition ||= create(:draft_edition)
  end

  def unpublishable_edition
    @unpublishable_edition ||= build(:draft_edition, title: nil)
  end
end
