require "test_helper"

class Admin::FeaturingsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    request.env["HTTP_REFERER"] = "http://example.com"
  end

  [:news_article, :consultation, :publication, :policy, :consultation_response, :international_priority, :speech].each do |edition_type|
    test "should not allow featuring a #{edition_type}" do
      edition = create("published_#{edition_type}")
      refute edition.featurable?
      post :create, edition_id: edition, edition: {}
      assert_redirected_to "http://example.com"
      assert_equal "#{edition_type.to_s.humanize.pluralize} cannot be featured", flash[:alert]
    end
  end

end
