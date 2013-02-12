require "test_helper"

class Whitehall::Uploader::AttachmentCacheTest < ActiveSupport::TestCase
  setup do
    @cache_root = Rails.root.join("tmp", "cache", "attachment-cache")
    FileUtils.mkdir_p(@cache_root)
    @cache = Whitehall::Uploader::AttachmentCache.new(@cache_root, Logger.new(StringIO.new))
    @pdf_path = Rails.root.join("test", "fixtures", "two-pages.pdf")
  end

  teardown do
    FileUtils.remove_dir(@cache_root, true)
  end

  test "returns successfully downloaded data" do
    url = "http://example.com/attachment.pdf"
    stub_request(:get, url).to_return(body: File.open(@pdf_path), status: 200)
    result = @cache.fetch(url)
    assert_equal File.read(@pdf_path), result.read
  end

  test "doesn't repeat requests for data which was already downloaded successfully" do
    url = "http://example.com/attachment.pdf"
    stub_request(:get, url).to_return(body: File.open(@pdf_path), status: 200).then.
      to_raise("shouldn't be called more than once!")
    first_result = @cache.fetch(url)
    second_result = @cache.fetch(url)
    assert_equal first_result.read, second_result.read, "cache should return the same values for the same URL"
  end

  test "doesn't cache requests that failed" do
    url = "http://example.com/attachment.pdf"
    stub_request(:get, url).to_return(body: "", status: 404).then.
      to_return(body: File.open(@pdf_path), status: 200)
    begin
      @cache.fetch(url)
    rescue Whitehall::Uploader::AttachmentCache::RetrievalError
    end
    second_result = @cache.fetch(url)
    assert_equal File.read(@pdf_path), second_result.read
  end

  test "follows 301 redirect and downloads attachment from new location" do
    old_url = "http://example.com/old.pdf"
    new_url = "http://example.com/new.pdf"
    stub_request(:get, old_url).to_return(body: "", status: 301, headers: {Location: new_url})
    stub_request(:get, new_url).to_return(body: File.open(@pdf_path), status: 200)
    result = @cache.fetch(old_url)
    assert_equal File.read(@pdf_path), result.read
  end

  test "follows 302 redirect and downloads attachment from new location" do
    old_url = "http://example.com/old.pdf"
    new_url = "http://example.com/new.pdf"
    stub_request(:get, old_url).to_return(body: "", status: 302, headers: {Location: new_url})
    stub_request(:get, new_url).to_return(body: File.open(@pdf_path), status: 200)
    result = @cache.fetch(old_url)
    assert_equal File.read(@pdf_path), result.read
  end

  test "allows attachments to be downloaded from https urls" do
    url = "https://example.com/attachment.pdf"
    stub_request(:get, url).to_return(body: File.open(@pdf_path), status: 200)
    result = @cache.fetch(url)
    assert_equal File.read(@pdf_path), result.read
  end

  test "allows attachments to be downloaded from urls with query strings" do
    url = "https://example.com/attachment.pdf?woo=hoo&oh=yeah"
    stub_request(:get, url).to_return(body: File.open(@pdf_path), status: 200)
    result = @cache.fetch(url)
    assert_equal File.read(@pdf_path), result.read
  end

  test "raises an error if the download didn't return a 200" do
    url = "http://example.com/attachment.pdf"
    stub_request(:get, url).to_return(body: "", status: 404)
    assert_raises_retrieval_error_matching(/got response status 404/) do
      @cache.fetch(url)
    end
  end

  test "raises an error if the download times out" do
    url = "http://example.com/attachment.pdf"
    stub_request(:get, url).to_timeout
    assert_raises_retrieval_error_matching(/due to Timeout/) do
      @cache.fetch(url)
    end
  end

  test "raises an error if the url is not valid" do
    url = "http://this is not a valid url"
    assert_raises_retrieval_error_matching(/due to invalid URL/) do
      @cache.fetch(url)
    end
  end

  test "raises an error if the url is not an http URL" do
    url = "this-is-not-even-http"
    assert_raises_retrieval_error_matching(/url not understood to be HTTP/) do
      @cache.fetch(url)
    end
  end

  test "uses the content-disposition header if present to determine the local filename" do
    url = "http://example.com/attachment"
    stub_request(:get, url).to_return(body: "",
      status: 200,
      headers: {"Content-Disposition" => 'attachment; filename="my-file.docx"'})
    assert_equal "my-file.docx", File.basename(@cache.fetch(url).path)
  end

  test "adds a PDF extension if the file is detected as a PDF but has no extension" do
    url = "http://example.com/attachment"
    stub_request(:get, url).to_return(body: "", status: 200)
    Whitehall::Uploader::AttachmentCache::FileTypeDetector.stubs(:detected_type).returns(:pdf)
    assert_equal "attachment.pdf", File.basename(@cache.fetch(url).path)
  end

  test "adds an XLS extension if the file is detected as an Excel file but has no extension" do
    url = "http://example.com/attachment"
    stub_request(:get, url).to_return(body: "", status: 200)
    Whitehall::Uploader::AttachmentCache::FileTypeDetector.stubs(:detected_type).returns(:xls)
    assert_equal "attachment.xls", File.basename(@cache.fetch(url).path)
  end

  test "adds an DOC extension if the file is detected as an Word file but has no extension" do
    url = "http://example.com/attachment"
    stub_request(:get, url).to_return(body: "", status: 200)
    Whitehall::Uploader::AttachmentCache::FileTypeDetector.stubs(:detected_type).returns(:doc)
    assert_equal "attachment.doc", File.basename(@cache.fetch(url).path)
  end

  private

  def assert_raises_retrieval_error_matching(message_regexp)
    yield
    flunk "Should raise a Whitehall::Uploader::AttachmentCache::RetrievalError"
  rescue Whitehall::Uploader::AttachmentCache::RetrievalError => e
    assert_match message_regexp, e.to_s
  end
end
