require "test_helper"

class Admin::FeaturingsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    request.env["HTTP_REFERER"] = "http://example.com"
  end

  [:news_article, :consultation, :publication, :policy, :international_priority, :speech].each do |edition_type|
    test "should not allow featuring a #{edition_type}" do
      edition = create("published_#{edition_type}")
      refute edition.featurable?
      post :create, edition_id: edition, edition: {}
      assert_redirected_to "http://example.com"
      assert_equal "#{edition_type.to_s.humanize.pluralize} cannot be featured", flash[:alert]
    end
  end

  test "should prevent access to inaccessible editions" do
    protected_edition = stub("protected edition", id: "1")
    protected_edition.stubs(:accessible_by?).with(@current_user).returns(false)
    Edition.stubs(:find).with("1").returns(protected_edition)

    get :create, edition_id: "1"
    assert_response 403
    get :update, edition_id: "1"
    assert_response 403
    get :destroy, edition_id: "1"
    assert_response 403
  end
end
