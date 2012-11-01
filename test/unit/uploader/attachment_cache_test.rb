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

  test "adds a PDF extension if the file is detected as a PDF but has no extension" do
    url = "http://example.com/attachment"
    stub_request(:get, url).to_return(body: File.open(@pdf_path), status: 200)
    assert_equal "attachment.pdf", File.basename(@cache.fetch(url).path)
  end

  private

  def assert_raises_retrieval_error_matching(message_regexp)
    yield
    flunk "Should raise a Whitehall::Uploader::AttachmentCache::RetrievalError"
  rescue Whitehall::Uploader::AttachmentCache::RetrievalError => e
    assert_match message_regexp, e.to_s
  end
end
