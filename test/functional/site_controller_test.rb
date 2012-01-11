require "test_helper"

class SiteControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

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
end