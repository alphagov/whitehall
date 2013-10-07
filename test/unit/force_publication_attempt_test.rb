require "test_helper"

class ForcePublicationAttemptTest < ActiveSupport::TestCase
  setup do
    @gds_team = create(:gds_editor, name: "GDS Inside Government Team")
  end

  test "records the start time and total number of documents to be force published" do
    stubbed_import = stub_import([build(:imported_edition), build(:imported_edition)])
    force_publish_attempt = ForcePublicationAttempt.create
    force_publish_attempt.stubs(:import).returns(stubbed_import)
    ForcePublisher::Worker.any_instance.stubs(:force_publish!)

    force_publish_attempt.perform

    assert_equal 2, force_publish_attempt.total_documents
    assert_equal Time.zone.now, force_publish_attempt.started_at
  end

  test "an edition that has a reason_to_prevent_force_publication is a failure, and won't be published" do
    failure_doc = stub_imported_document
    failure_doc.stubs(:reason_to_prevent_force_publication).returns('it is badly written')
    failure_doc.expects(:perform_force_publish).never

    stubbed_import = stub_import([failure_doc])
    force_publish_attempt = ForcePublicationAttempt.create
    force_publish_attempt.stubs(:import).returns(stubbed_import)

    force_publish_attempt.perform
    assert_equal 0, force_publish_attempt.successful_documents
    assert_equal 1, force_publish_attempt.failed_documents
    assert force_publish_attempt.successes.empty?
  end

  test "an edition that has a reason_to_prevent_force_publication is logged as a failure with the reason" do
    failure_doc = stub_imported_document
    failure_doc.stubs(:reason_to_prevent_force_publication).returns('it is badly written')
    failure_doc.expects(:perform_force_publish).never

    stubbed_import = stub_import([failure_doc])
    force_publish_attempt = ForcePublicationAttempt.create
    force_publish_attempt.stubs(:import).returns stubbed_import

    force_publish_attempt.progress_logger.expects(:failure).with(failure_doc, 'it is badly written')

    force_publish_attempt.perform
  end

  test 'an edition that has no reason_to_prevent_force_publication but fails to perform_force_publish is a failure' do
    failure_doc = stub_imported_document
    failure_doc.stubs(:reason_to_prevent_force_publication).returns(nil)
    failure_doc.stubs(:perform_force_publish).raises(ArgumentError.new('eek!'))

    stubbed_import = stub_import([failure_doc])
    force_publish_attempt = ForcePublicationAttempt.create
    force_publish_attempt.stubs(:import).returns stubbed_import

    force_publish_attempt.perform
    assert_equal 0, force_publish_attempt.successful_documents
    assert_equal 1, force_publish_attempt.failed_documents
    assert force_publish_attempt.successes.empty?
  end

  test 'an edition that has no reason_to_prevent_force_publication but fails to perform_force_publish is logged as a failure with the raised exception' do
    failure_doc = stub_imported_document
    failure_doc.stubs(:reason_to_prevent_force_publication).returns(nil)
    exception = ArgumentError.new('eek!')
    failure_doc.stubs(:perform_force_publish).raises(exception)

    stubbed_import = stub_import([failure_doc])
    force_publish_attempt = ForcePublicationAttempt.create
    force_publish_attempt.stubs(:import).returns stubbed_import

    force_publish_attempt.progress_logger.expects(:failure).with(failure_doc, exception)

    force_publish_attempt.perform
  end

  test 'an edition that has no reason_to_prevent_force_publication and doesn\'t break when asked to perform_force_publish is a success' do
    success_doc = stub_imported_document
    success_doc.stubs(:reason_to_prevent_force_publication).returns(nil)
    success_doc.stubs(:perform_force_publish).returns(true)

    stubbed_import = stub_import([success_doc])
    force_publish_attempt = ForcePublicationAttempt.create
    force_publish_attempt.stubs(:import).returns stubbed_import

    force_publish_attempt.perform

    assert_equal 1, force_publish_attempt.successful_documents
    assert_equal 0, force_publish_attempt.failed_documents
    assert force_publish_attempt.successes.include?(success_doc)
  end

  test 'an edition that has no reason_to_prevent_force_publication and doesn\'t break when asked to perform_force_publish is logged as a success' do
    success_doc = stub_imported_document
    success_doc.stubs(:reason_to_prevent_force_publication).returns(nil)
    success_doc.stubs(:perform_force_publish).returns(true)

    stubbed_import = stub_import([success_doc])
    force_publish_attempt = ForcePublicationAttempt.create
    force_publish_attempt.stubs(:import).returns stubbed_import

    force_publish_attempt.progress_logger.expects(:success).with(success_doc)

    force_publish_attempt.perform
  end

  test "records the finish time and total number of documents successfully published" do
    stubbed_import = stub_import([stub_successful_document, stub_failure_document])
    force_publish_attempt = ForcePublicationAttempt.create()
    force_publish_attempt.stubs(:import).returns stubbed_import

    force_publish_attempt.perform

    assert_equal 1, force_publish_attempt.successful_documents
    assert_equal 1, force_publish_attempt.failed_documents
    assert_equal Time.zone.now, force_publish_attempt.finished_at
  end

  def stub_import(force_publishable_editions)
    stub(:import).tap do |stubbed_import|
      stubbed_import.stubs(:force_publishable_editions).returns(force_publishable_editions)
      stubbed_import.stubs(:force_publishable_edition_count).returns(force_publishable_editions.size)
    end
  end

  def stub_imported_document
    edition = build(:imported_edition)
    edition.stubs(:id).returns 10
    doc = build(:document)
    doc.stubs(:id).returns 11
    edition.stubs(:document).returns doc
    edition
  end

  def stub_successful_document
    success_doc = stub_imported_document
    success_doc.stubs(:reason_to_prevent_force_publication).returns(nil)
    success_doc.stubs(:perform_force_publish).returns(true)
    success_doc
  end

  def stub_failure_document
    fail_doc = stub_imported_document
    fail_doc.stubs(:reason_to_prevent_force_publication).returns('it smells')
    fail_doc
  end
end
