require "test_helper"

class Admin::FeaturingsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  [:publication, :consultation, :news_article].each do |document_type|
    test "featuring a published #{document_type} sets the featured flag" do
      request.env["HTTP_REFERER"] = "http://example.com"
      document = create("published_#{document_type}")
      post :create, document_id: document
      assert document.reload.featured?
    end

    test "featuring a #{document_type} redirects the user back to where they came from" do
      request.env["HTTP_REFERER"] = "http://example.com"
      document = create("published_#{document_type}")
      post :create, document_id: document
      assert_redirected_to "http://example.com"
    end

    test "unfeaturing a #{document_type} removes the featured flag" do
      request.env["HTTP_REFERER"] = "http://example.com"
      document = create("featured_#{document_type}")
      delete :destroy, document_id: document
      refute document.reload.featured?
    end

    test "unfeaturing a #{document_type} redirects the user back to where they came from" do
      request.env["HTTP_REFERER"] = "http://example.com"
      document = create("featured_#{document_type}")
      delete :destroy, document_id: document
      assert_redirected_to "http://example.com"
    end
  end

  [:policy, :consultation_response, :international_priority, :speech].each do |document_type|
    test "should not allow featuring a #{document_type}" do
      request.env["HTTP_REFERER"] = "http://example.com"
      document = create("published_#{document_type}")
      refute document.featurable?
      post :create, document_id: document
      assert_redirected_to "http://example.com"
      assert_equal "#{document_type.to_s.humanize.pluralize} cannot be featured", flash[:alert]
    end
  end
end
