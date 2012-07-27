require "test_helper"

class SearchClientTest < ActiveSupport::TestCase
  setup do
    stub_request(:get, /example.com\/search/).to_return(body: "[]")
    stub_request(:get, /example.com\/autocomplete/).to_return(body: "[]")
  end

  test "should raise an exception if the search service uri is not set" do
    assert_raise(Whitehall::SearchClient::SearchUriNotSpecified) { Whitehall::SearchClient.new(nil) }
  end

  test "should return the search deserialized from json" do
    search_results = [{"title" => "document-title"}]
    stub_request(:get, /example.com\/search/).to_return(body: search_results.to_json)
    results = Whitehall::SearchClient.new("http://example.com").search("query")

    assert_equal search_results, results
  end

  test "should return an empty set of results without making request if query is empty" do
    results = Whitehall::SearchClient.new("http://example.com").search("")

    assert_equal [], results
    assert_not_requested :get, /example.com/
  end

  test "should return an empty set of results without making request if query is nil" do
    results = Whitehall::SearchClient.new("http://example.com").search(nil)

    assert_equal [], results
    assert_not_requested :get, /example.com/
  end

  test "should request the search results in JSON format" do
    Whitehall::SearchClient.new("http://example.com").search("query")

    assert_requested :get, /.*/, headers: {"Accept" => "application/json"}
  end

  test "should issue a request for the search term specified" do
    Whitehall::SearchClient.new("http://example.com").search "search-term"

    assert_requested :get, /\?q=search-term/
  end

  test "should add a format filter parameter to searches if provided" do
    Whitehall::SearchClient.new("http://example.com").search "search-term", "specialist_guide"

    assert_requested :get, /format_filter=specialist_guide/
  end

  test "should add a format filter parameter to autocomplete if provided" do
    Whitehall::SearchClient.new("http://example.com").autocomplete "search-term", "specialist_guide"

    assert_requested :get, /format_filter=specialist_guide/
  end

  test "should escape characters that would otherwise be invalid in a URI" do
    Whitehall::SearchClient.new("http://example.com").search "search term with spaces"

    # FYI: the actual request is "?q=search+term+with+spaces", but Webmock appears to be re-escaping.
    assert_requested :get, /\?q=search%20term%20with%20spaces/
  end

  test "should pass autocomplete responses back as-is" do
    search_results_json = {"title" => "document-title"}.to_json
    stub_request(:get, /example.com\/autocomplete/).to_return(body: search_results_json)
    results = Whitehall::SearchClient.new("http://example.com").autocomplete("")

    assert_equal search_results_json, results
  end
end