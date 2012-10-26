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
    DocumentSource.stubs(:create!)
  end

  test 'builds row class with each csv row' do
    @row_class.expects(:new).with({'header-a' => 'a1', 'header-b' => 'b1', 'header-c' => 'c1'}, 1, anything).returns(@row)
    Whitehall::Uploader::Csv.new(@data, @row_class, @model_class).import_as(@user)
  end

  test 'builds model with attributes from each row' do
    @model_class.expects(:new).with(row: :one, creator: @user).returns(@model)
    Whitehall::Uploader::Csv.new(@data, @row_class, @model_class).import_as(@user)
  end

  test 'records model import if save successful' do
    @model.stubs(:save).returns(true)
    DocumentSource.expects(:create!).with(document: @document, url: 'row-legacy-url')
    Whitehall::Uploader::Csv.new(@data, @row_class, @model_class).import_as(@user)
  end

  test 'logs failure if save unsuccessful' do
    @errors = stub('errors', full_messages: "Feeling funky")
    @model.stubs(:save).returns(false)
    @model.stubs(:errors).returns(@errors)

    log_buffer = StringIO.new
    Whitehall::Uploader::Csv.new(@data, @row_class, @model_class, Logger.new(log_buffer)).import_as(@user)
    assert_match /Row 2 'row-legacy-url' couldn't be saved for the following reasons: Feeling funky/, log_buffer.string
  end
end
