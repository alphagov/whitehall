require "test_helper"

class Admin::FeaturingsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    request.env["HTTP_REFERER"] = "http://example.com"
  end

  [:news_article].each do |edition_type|
    test "featuring a published #{edition_type} sets the featured flag" do
      edition = create("published_#{edition_type}")
      post :create, edition_id: edition, edition: {}
      assert edition.reload.featured?
    end

    test "featuring a #{edition_type} redirects the user back to where they came from" do
      edition = create("published_#{edition_type}")
      post :create, edition_id: edition, edition: {}
      assert_redirected_to "http://example.com"
    end

    test "unfeaturing a #{edition_type} removes the featured flag" do
      edition = create("featured_#{edition_type}")
      delete :destroy, edition_id: edition, edition: {}
      refute edition.reload.featured?
    end

    test "unfeaturing a #{edition_type} redirects the user back to where they came from" do
      edition = create("featured_#{edition_type}")
      delete :destroy, edition_id: edition, edition: {}
      assert_redirected_to "http://example.com"
    end
  end

  [:consultation, :publication, :policy, :consultation_response, :international_priority, :speech].each do |edition_type|
    test "should not allow featuring a #{edition_type}" do
      edition = create("published_#{edition_type}")
      refute edition.featurable?
      post :create, edition_id: edition, edition: {}
      assert_redirected_to "http://example.com"
      assert_equal "#{edition_type.to_s.humanize.pluralize} cannot be featured", flash[:alert]
    end
  end

  test "update should redirect the user back whence they came" do
    news_article = create(:featured_news_article)
    put :update, edition_id: news_article
    assert_redirected_to "http://example.com"
  end
end
