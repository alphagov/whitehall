require "test_helper"

module ConsultationCsvSampleHelpers
  def csv_sample(additional_fields = {}, extra_rows = [])
    data = minimally_valid_row.merge(additional_fields)
    lines = []
    lines << CSV.generate_line(data.keys, encoding: "UTF-8")
    lines << CSV.generate_line(data.values, encoding: "UTF-8")
    extra_rows.each do |row|
      lines << CSV.generate_line(default_row.merge(row).values, encoding: "UTF-8")
    end
    lines.join
  end

  def minimally_valid_row
    {
      "old_url"          => "http://example.com",
      "title"            => "title",
      "summary"          => "summary",
      "body"             => "body",
      "opening_date" => "11/16/2011",
      "closing_date" => "11/16/2012",
      "organisation"     => sample_organisation.slug,
      "policy_1" => "",
      "policy_2" => "",
      "policy_3" => "",
      "policy_4" => "",
      "minister_1" => "",
      "minister_2" => "",
      "respond_url" => "",
      "respond_email" => "",
      "respond_postal_address" => "",
      "respond_form_title" => "",
      "respond_form_attachment" => "",
      "consultation_ISBN" => "",
      "consultation_URN" => "",
      "publication_date" => "",
      "order_url" => "",
      "command_paper_number" => "",
      "price" => "",
      "response_date" => "",
      "response_summary" => "",
      "comments" => ""
    }
  end

  def sample_organisation
    @sample_organisation ||= (Organisation.first || create(:organisation))
  end
end

class ImportTest < ActiveSupport::TestCase
  include ConsultationCsvSampleHelpers

  test "valid if known type" do
    assert Import.new(csv_data: csv_sample, data_type: "consultation").valid?
  end

  test "invalid if unknown type" do
    refute Import.new(csv_data: csv_sample, data_type: "not_valid").valid?
  end

  test 'invalid if row is invalid for the given data' do
    Whitehall::Uploader::ConsultationRow.stubs(:heading_validation_errors).with(['a']).returns(["Bad stuff"])
    i = Import.new(csv_data: "a\n1", creator: stub_record(:user), data_type: "consultation")
    refute i.valid?
    assert_equal ["Bad stuff"], i.errors[:csv_data]
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
    i = Import.create!(csv_data: csv_sample, creator: @user, data_type: "consultation")
    i.stubs(:row_class).returns(@row_class)
    i.stubs(:model_class).returns(@model_class)
    DocumentSource.expects(:create!).with(document: @document, url: @row.legacy_url, import: i, row_number: 2)
    i.perform
  end

  test 'logs failure if save unsuccessful' do
    @errors = stub('errors', full_messages: ["Feeling funky"])
    @model.stubs(:save).returns(false)
    @model.stubs(:errors).returns(@errors)
    @model.stubs(:attachments).returns([])

    @progress_logger.expects(:error).with(2, "Feeling funky")

    i = Import.new(csv_data: @data, creator: @user)
    i.stubs(:row_class).returns(@row_class)
    i.stubs(:model_class).returns(@model_class)
    i.perform(
      attachment_cache: @attachment_cache,
      progress_logger: @progress_logger
    )
  end

  test 'logs failures within attachments if save unsuccessful' do
    @errors = stub('errors', full_messages: [])
    @model.stubs(:save).returns(false)
    @model.stubs(:errors).returns(@errors)
    attachment = stub('attachment', errors: stub('attachment-errors', full_messages: 'attachment error'))
    attachment.stubs(:valid?).returns(false)
    attachment.stubs(:attachment_source).returns(stub('attachment-source', url: 'url'))
    @model.stubs(:attachments).returns([attachment])

    @progress_logger.expects(:error).with(2, "Attachment 'url' error: attachment error")

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
