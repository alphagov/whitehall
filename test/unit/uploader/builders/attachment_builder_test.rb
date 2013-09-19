require "test_helper"
require 'support/importer_test_logger'

class Whitehall::Uploader::Builders::AttachmentBuilderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = ImporterTestLogger.new(@log_buffer)
    @line_number = 1

    @cache = stub(:attachment_cache)
    tmp_attachment_path = Rails.root.join("test", "fixtures", "two-pages.pdf")
    @cache.stubs(:fetch).returns(File.open(tmp_attachment_path))

    @url = "http://example.com/attachment.pdf"
    stub_request(:get, @url).to_return(body: "some-data".force_encoding("ASCII-8BIT"), status: 200)
    @title = "attachment title"
  end

  test "downloads an attachment from the URL given" do
    attachment = Whitehall::Uploader::Builders::AttachmentBuilder.build({title: @title}, @url, @cache, @log, @line_number)
    assert attachment.file.present?
  end

  test "does nothing if both title and url blank" do
    attachment = Whitehall::Uploader::Builders::AttachmentBuilder.build({title: ""}, "", @cache, @log, @line_number)
    assert attachment.nil?
  end

  test "stores the attachment title" do
    attachment = Whitehall::Uploader::Builders::AttachmentBuilder.build({title: @title}, @url, @cache, @log, @line_number)
    assert_equal "attachment title", attachment.title
  end

  test "stores the attachment unique reference if given" do
    attachment = Whitehall::Uploader::Builders::AttachmentBuilder.build({title: @title, unique_reference: "abc"}, @url, @cache, @log, @line_number)
    assert_equal "abc", attachment.unique_reference
  end

  test "stores the original URL against the attachment source" do
    attachment = Whitehall::Uploader::Builders::AttachmentBuilder.build({title: @title}, @url, @cache, @log, @line_number)
    assert_equal @url, attachment.attachment_source.url
  end

  test "logs a warning if cache couldn't find the attachment" do
    @cache.stubs(:fetch).raises(Whitehall::Uploader::AttachmentCache::RetrievalError.new("some error to do with attachment retrieval"))
    Whitehall::Uploader::Builders::AttachmentBuilder.build({title: @title}, @url, @cache, @log, @line_number)
    assert_match /Unable to fetch attachment .* some error to do with attachment retrieval/, @log_buffer.string
  end
end
