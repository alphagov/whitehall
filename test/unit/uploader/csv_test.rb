require 'test_helper'

class Whitehall::Uploader::CsvTest < ActiveSupport::TestCase
  setup do
    @row = stub('row', attributes: {row: :one}, legacy_url: 'row-legacy-url')
    @row_class = stub('row-class', new: @row)
    @data = "header-a,header-b,header-c\na1,b1,c1"

    @document = stub('document')
    @model = stub('model', save: true, document: @document)
    @model_class = stub('model-class', new: @model)

    @user = stub('user')
    DocumentSource.stubs(:find_by_url).returns(nil)
    DocumentSource.stubs(:create!)

    @log_buffer = StringIO.new
    @error_csv_path = Rails.root.join("tmp", "error_import.csv")
    @attachment_cache = stub('attachment cache')
  end

  teardown do
    File.unlink(@error_csv_path) if File.exist?(@error_csv_path)
  end

  test 'builds row class with each csv row and the attachment cache' do
    @row_class.expects(:new).with({'header-a' => 'a1', 'header-b' => 'b1', 'header-c' => 'c1'}, 1, @attachment_cache, anything).returns(@row)
    Whitehall::Uploader::Csv.new(@data, @row_class, @model_class, @attachment_cache).import_as(@user)
  end

  test 'builds model with attributes from each row' do
    @model_class.expects(:new).with(row: :one, creator: @user).returns(@model)
    Whitehall::Uploader::Csv.new(@data, @row_class, @model_class, @attachment_cache).import_as(@user)
  end

  test 'records model import if save successful' do
    @model.stubs(:save).returns(true)
    DocumentSource.expects(:create!).with(document: @document, url: 'row-legacy-url')
    Whitehall::Uploader::Csv.new(@data, @row_class, @model_class, @attachment_cache).import_as(@user)
  end

  test 'skips row import if url already uploaded' do
    DocumentSource.unstub(:create!)
    DocumentSource.stubs(:find_by_url).with('row-legacy-url').returns('document')
    DocumentSource.expects(:create!).never
    Whitehall::Uploader::Csv.new(@data, @row_class, @model_class, @attachment_cache, Logger.new(@log_buffer), @error_csv_path).import_as(@user)
    assert_match /'row-legacy-url' has already been imported/, @log_buffer.string
  end

  test 'logs failure if save unsuccessful' do
    @errors = stub('errors', full_messages: ["Feeling funky"])
    @model.stubs(:save).returns(false)
    @model.stubs(:errors).returns(@errors)
    @model.stubs(:attachments).returns([])

    Whitehall::Uploader::Csv.new(@data, @row_class, @model_class, @attachment_cache, Logger.new(@log_buffer), @error_csv_path).import_as(@user)
    assert_match /Row 2 'row-legacy-url' couldn't be saved for the following reasons:.*Feeling funky.*/, @log_buffer.string
  end

  test 'logs failures within attachments if save unsuccessful' do
    @errors = stub('errors', full_messages: ["Feeling funky"])
    @model.stubs(:save).returns(false)
    @model.stubs(:errors).returns(@errors)
    attachment = stub('attachment', errors: stub('attachment-errors', full_messages: 'attachment error'))
    attachment.stubs(:valid?).returns(false)
    attachment.stubs(:attachment_source).returns(stub('attachment-source', url: 'url'))
    @model.stubs(:attachments).returns([attachment])

    Whitehall::Uploader::Csv.new(@data, @row_class, @model_class, @attachment_cache, Logger.new(@log_buffer), @error_csv_path).import_as(@user)
    assert_match /Row 2 'row-legacy-url' couldn't be saved for the following reasons:.*attachment error.*/, @log_buffer.string
  end

  test 'stores CSV of failure rows' do
    @errors = stub('errors', full_messages: ["Feeling funky"])
    @model.stubs(:save).returns(false)
    @model.stubs(:errors).returns(@errors)
    @model.stubs(:attachments).returns([])

    Whitehall::Uploader::Csv.new(@data, @row_class, @model_class, @attachment_cache, Logger.new(@log_buffer), @error_csv_path).import_as(@user)

    error_csv = CSV.read(@error_csv_path, headers: true)
    assert_equal 1, error_csv.length
    assert_equal "a1", error_csv[0]["header-a"]
    assert_equal "b1", error_csv[0]["header-b"]
    assert_equal "c1", error_csv[0]["header-c"]
    assert_equal "Feeling funky", error_csv[0]["import_error_messages"]
  end

  test 'stores CSV of failure rows which raise exceptions' do
    @model.stubs(:save).raises("Something awful happened")

    Whitehall::Uploader::Csv.new(@data, @row_class, @model_class, @attachment_cache, Logger.new(@log_buffer), @error_csv_path).import_as(@user)

    error_csv = CSV.read(@error_csv_path, headers: true)
    assert_equal 1, error_csv.length
    assert_equal "a1", error_csv[0]["header-a"]
    assert_equal "b1", error_csv[0]["header-b"]
    assert_equal "c1", error_csv[0]["header-c"]
    assert_equal "Something awful happened", error_csv[0]["import_error_messages"]
  end

  test "doesn't output any errors if there weren't any" do
    Whitehall::Uploader::Csv.new(@data, @row_class, @model_class, @attachment_cache, Logger.new(@log_buffer), @error_csv_path).import_as(@user)
    refute File.exist?(@error_csv_path)
  end
end
