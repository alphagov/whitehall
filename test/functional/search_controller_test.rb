require "test_helper"

class SearchControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "should ask the user to enter a search term if none was given" do
    client = stub("search", search: [])
    Whitehall.stubs(:search_client).returns(client)
    get :index, q: ""
    assert_select "h1", %{Enter a few words to start searching}
    assert_select "form[action=?]", search_path do
      assert_select "input[name=q]"
    end
  end

  test "should inform the user that we didn't find any documents matching the search term" do
    client = stub("search", search: [])
    Whitehall.stubs(:search_client).returns(client)
    get :index, q: "search-term"
    assert_select "p", text: %Q{We can't find any results for "search-term".}
  end

  test "should pass our query parameter in to the search client" do
    client = stub("search")
    Whitehall.stubs(:search_client).returns(client)
    client.expects(:search).with("search-term").returns([])
    get :index, q: "search-term"
  end

  test "should include the term we search for in the page header" do
    client = stub("search", search: [])
    Whitehall.stubs(:search_client).returns(client)
    get :index, q: "search-term"
    assert_select "h1", text: /search-term/
  end

  test "should display the number of results" do
    client = stub("search", search: [{}, {}, {}])
    Whitehall.stubs(:search_client).returns(client)
    get :index, q: "search-term"
    assert_select "h1", text: /3 results/
  end

  test "should display a link to the documents matching our search criteria" do
    client = stub("search", search: [{"title" => "document-title", "link" => "/document-slug"}])
    Whitehall.stubs(:search_client).returns(client)
    get :index, q: "search-term"
    assert_select "a[href='/document-slug']", text: "document-title"
  end

  test "should display the highlighted text from the search result" do
    client = stub("search", search: [{"title" => "title", "link" => "/slug", "highlight" => "the HIGHLIGHT_STARTmatchHIGHLIGHT_END for"}])
    Whitehall.stubs(:search_client).returns(client)
    get :index, q: "search-term"
    assert_select ".highlight", text: "&hellip;the match for&hellip;" do
      assert_select "strong", text: "match"
    end
  end

  test "should set the class of the result according to the format" do
    client = stub("search", search: [{"title" => "title", "link" => "/slug", "highlight" => "", "format" => "publication"}])
    Whitehall.stubs(:search_client).returns(client)
    get :index, q: "search-term"
    assert_select ".search_results .publication"
  end

  test "should be capable of responding with JSON results" do
    results = [
      {"title" => "document-title-1", "link" => "/document-slug-1"},
      {"title" => "document-title-2", "link" => "/document-slug-2"}
    ]
    client = stub("search", search: results)
    Whitehall.stubs(:search_client).returns(client)
    get :index, q: "search-term", format: :json
    data = JSON.parse(response.body)
    assert_equal results, data
  end

  test "should return the response from autocomplete as a string" do
    client = stub("search")
    Whitehall.stubs(:search_client).returns(client)
    raw_rummager_response = "rummager-response-body-json"
    client.expects(:autocomplete).with("search-term").returns(raw_rummager_response)
    get :autocomplete, q: "search-term"
    assert_equal raw_rummager_response, @response.body
  end

  test "should return an empty autocomplete list on an empty query" do
    get :autocomplete

    assert_equal "[]", @response.body
  end

  test "should display a link to search the citizen proposition" do
    client = stub("search", search: [])
    Whitehall.stubs(:search_client).returns(client)

    get :index, q: "search-term"

    assert_select "a[href='/search?q=search-term']"
  end

  test "should display a link to search the citizen proposition with search term requiring escaping" do
    client = stub("search", search: [])
    Whitehall.stubs(:search_client).returns(client)

    get :index, q: "search+term"

    assert_select "a[href='/search?q=search%2Bterm']"
  end
end
