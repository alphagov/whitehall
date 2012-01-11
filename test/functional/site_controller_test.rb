require "test_helper"

class SiteControllerTest < ActionController::TestCase
  test "index shows a list of recently published documents" do
    5.downto(1) do |x|
      create(:published_policy, published_at: x.days.ago)
      create(:published_news_article, published_at: x.days.ago)
      create(:published_speech, published_at: x.days.ago)
      create(:published_publication, published_at: x.days.ago)
      create(:published_consultation, published_at: x.days.ago)
    end
    draft_documents = [create(:draft_policy), create(:draft_news_article),
                       create(:draft_speech), create(:draft_consultation),
                       create(:draft_publication)]

    get :index

    documents = Document.published.by_published_at
    recent_documents = documents[0...10]
    older_documents = documents[10..-1]

    recent_documents.each { |d| assert_select_object(d) }
    older_documents.each { |d| refute_select_object(d) }
    draft_documents.each { |d| refute_select_object(d) }
  end

  test "index responds with 304 if previous request is still fresh" do
    last_modified_from_previous_request = 1.day.ago
    create(:published_policy, published_at: last_modified_from_previous_request)
    request.env["HTTP_IF_MODIFIED_SINCE"] = last_modified_from_previous_request.utc.httpdate

    get :index
    assert_equal 304, response.status
  end

  test "index responds with 200 if previous request is now stale" do
    last_modified_from_previous_request = 1.day.ago
    create(:published_policy, published_at: Time.zone.now)
    request.env["HTTP_IF_MODIFIED_SINCE"] = last_modified_from_previous_request.utc.httpdate

    get :index
    assert_equal 200, response.status
  end
end