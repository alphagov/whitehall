require "test_helper"
require 'support/consultation_csv_sample_helpers'

class ImportTest < ActiveSupport::TestCase
  include ConsultationCsvSampleHelpers

  test "valid if known type" do
    i = Import.new(csv_data: consultation_csv_sample, data_type: "consultation")
    assert i.valid?, i.errors.full_messages.to_s
  end

  test "invalid if unknown type" do
    refute Import.new(csv_data: consultation_csv_sample, data_type: "not_valid").valid?
  end

  test 'invalid if row is invalid for the given data' do
    Whitehall::Uploader::ConsultationRow.stubs(:heading_validation_errors).with(['a']).returns(["Bad stuff"])
    i = Import.new(csv_data: "a\n1", creator: stub_record(:user), data_type: "consultation")
    refute i.valid?
    assert_equal ["Bad stuff"], i.errors[:csv_data]
  end

  test "doesn't raise if some headings are blank" do
    i = Import.new(csv_data: "a,,b\n1,,3", creator: stub_record(:user), data_type: "consultation")
    begin
      assert i.headers
    rescue => e
      fail e
    end
  end
end

class ImportSavingTest < ActiveSupport::TestCase
  include ConsultationCsvSampleHelpers

  setup do
    @row = stub('row', attributes: {row: :one}, legacy_url: 'row-legacy-url', valid?: true)
    @row_class = stub('row-class', new: @row, heading_validation_errors: [])
    @data = "header-a,header-b,header-c\na1,b1,c1"

    @document = stub('document')
    @model = stub('model', save: true, document: @document)
    @model_class = stub('model-class', new: @model)

    @user = stub_record(:user)
    DocumentSource.stubs(:find_by_url).returns(nil)
    DocumentSource.stubs(:create!)
    @progress_logger = stub_everything("progress logger")
  end

  test "#perform notifies the progress logger of start" do
    i = Import.new(csv_data: "a\n1", creator: @user, data_type: "consultation")
    i.stubs(:row_class).returns(@row_class)
    i.stubs(:model_class).returns(@model_class)
    i.save
    @progress_logger.expects(:start)
    i.perform(progress_logger: @progress_logger)
  end

  test "#perform records the document source of successfully imported records" do
    i = Import.create!(csv_data: consultation_csv_sample, creator: @user, data_type: "consultation")
    i.stubs(:row_class).returns(@row_class)
    i.stubs(:model_class).returns(@model_class)
    DocumentSource.expects(:create!).with(document: @document, url: @row.legacy_url, import: i, row_number: 2)
    i.perform
  end

  test 'logs failure if save unsuccessful' do
    @errors = {body: ["required"]}
    @model.stubs(:save).returns(false)
    @model.stubs(:errors).returns(@errors)
    @model.stubs(:attachments).returns([])

    @progress_logger.expects(:error).with(2, "body: required")

    i = Import.new(csv_data: @data, creator: @user)
    i.stubs(:row_class).returns(@row_class)
    i.stubs(:model_class).returns(@model_class)
    i.perform(
      attachment_cache: @attachment_cache,
      progress_logger: @progress_logger
    )
  end

  test 'logs failures within attachments if save unsuccessful' do
    @errors = {attachments: ["is invalid"]}
    @model.stubs(:save).returns(false)
    @model.stubs(:errors).returns(@errors)
    attachment = stub('attachment', errors: stub('attachment-errors', full_messages: 'attachment error'))
    attachment.stubs(:valid?).returns(false)
    attachment.stubs(:attachment_source).returns(stub('attachment-source', url: 'url'))
    @model.stubs(:attachments).returns([attachment])

    @progress_logger.expects(:error).with(2, "Attachment 'url': attachment error")

    i = Import.new(csv_data: @data, creator: @user)
    i.stubs(:row_class).returns(@row_class)
    i.stubs(:model_class).returns(@model_class)
    i.perform(
      attachment_cache: @attachment_cache,
      progress_logger: @progress_logger
    )
  end

  test 'logs errors for exceptions' do
    @model.stubs(:save).raises("Something awful happened")

    @progress_logger.expects(:error).with(2, regexp_matches(/Something awful happened/))

    i = Import.new(csv_data: @data, creator: @user)
    i.stubs(:row_class).returns(@row_class)
    i.stubs(:model_class).returns(@model_class)
    i.perform(
      attachment_cache: @attachment_cache,
      progress_logger: @progress_logger
    )
  end
end
