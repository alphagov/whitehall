require "test_helper"

class PoliciesControllerTest < ActionController::TestCase
  test "should show inapplicable nations" do
    published_policy = create(:published_policy)
    published_policy.nations << Nation.wales

    get :show, id: published_policy.document_identity

    assert_select "#inapplicable_nations", "This policy does not apply to Northern Ireland and Scotland."
  end

  test "should show related documents" do
    related_publication = create(:published_publication, title: "Voting Patterns")
    published_policy = create(:published_policy, documents_related_with: [related_publication])

    get :show, id: published_policy.document_identity

    assert_select "#related-documents" do
      assert_select_object related_publication
    end
  end
end