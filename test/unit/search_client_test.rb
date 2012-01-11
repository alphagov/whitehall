require "test_helper"

class SearchClientTest < ActiveSupport::TestCase
  setup do
    Whitehall::SearchClient.search_uri = "http://example.com"
    stub_request(:get, /example.com/).to_return(body: "[]")
  end

  test "should raise an exception if the search service uri is not set" do
    Whitehall::SearchClient.search_uri = nil
    client = Whitehall::SearchClient.new
    assert_raise(Whitehall::SearchClient::SearchUriNotSpecified) { client.search("") }
  end

  test "should return the search results as a hash" do
    search_results = {"title" => "document-title"}
    stub_request(:get, /example.com/).to_return(body: search_results.to_json)
    results = Whitehall::SearchClient.new.search("")

    assert_equal search_results, results
  end

  test "should request the search results in JSON format" do
    Whitehall::SearchClient.new.search ""

    assert_requested :get, /.*/, headers: {"Accept" => "application/json"}
  end

  test "should issue a request for the search term specified" do
    Whitehall::SearchClient.new.search "search-term"

    assert_requested :get, /\?q=search-term/
  end
end