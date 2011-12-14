require "test_helper"

class SearchesControllerTest < ActionController::TestCase
  test "should display policy with title containing search term" do
    policy = create(:published_policy, title: "Ban beards")

    get :show, q: "beard"

    assert_select ".search_results" do
      assert_select_object policy
    end
  end

  test "should display policies in search results" do
    policy = create(:published_policy, title: "Ban beards")

    get :show, q: "beard"

    assert_select ".search_results" do
      assert_select "a[href='#{policy_path(policy.document_identity)}']", text: policy.title
    end
  end

  test "should indicate how many search results were found" do
    create(:published_policy, title: "Ban beards")
    create(:published_policy, title: "Beards are the best")

    get :show, q: "beard"

    assert_select ".search_results .count", text: "2 documents matched your query."
  end

  test "should populate search query input field" do
    get :show, q: "beard"

    assert_select "input[name='q'][value='beard']"
  end

  test "should indicate that no search results were found if there are none" do
    get :show, q: "beard"

    assert_select ".search_results .count", text: "0 documents matched your query."
  end

  test "should not attempt search if no query specified" do
    Document.expects(:search).never

    get :show
  end

  test "should not show search results if no query specified" do
    get :show

    refute_select ".search_results"
  end

  test "should not attempt search if blank query specified" do
    Document.expects(:search).never

    get :show, q: ""
  end

  test "should not show search results if blank query specified" do
    get :show, q: ""

    refute_select ".search_results"
  end
end
