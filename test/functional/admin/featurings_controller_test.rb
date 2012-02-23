require "test_helper"

class Admin::FeaturingsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    request.env["HTTP_REFERER"] = "http://example.com"
  end

  [:publication, :consultation, :news_article].each do |document_type|
    test "featuring a published #{document_type} sets the featured flag" do
      document = create("published_#{document_type}")
      post :create, document_id: document, document: {}
      assert document.reload.featured?
    end

    test "featuring a #{document_type} redirects the user back to where they came from" do
      document = create("published_#{document_type}")
      post :create, document_id: document, document: {}
      assert_redirected_to "http://example.com"
    end

    test "unfeaturing a #{document_type} removes the featured flag" do
      document = create("featured_#{document_type}")
      delete :destroy, document_id: document, document: {}
      refute document.reload.featured?
    end

    test "unfeaturing a #{document_type} redirects the user back to where they came from" do
      document = create("featured_#{document_type}")
      delete :destroy, document_id: document, document: {}
      assert_redirected_to "http://example.com"
    end
  end

  [:policy, :consultation_response, :international_priority, :speech].each do |document_type|
    test "should not allow featuring a #{document_type}" do
      document = create("published_#{document_type}")
      refute document.featurable?
      post :create, document_id: document, document: {}
      assert_redirected_to "http://example.com"
      assert_equal "#{document_type.to_s.humanize.pluralize} cannot be featured", flash[:alert]
    end
  end

  test "update should redirect the user back whence they came" do
    news_article = create(:featured_news_article)
    put :update, document_id: news_article
    assert_redirected_to "http://example.com"
  end
end
