require "test_helper"

class PoliciesControllerTest < ActionController::TestCase
  test "should show inapplicable nations" do
    published_policy = create(:published_policy)
    northern_ireland_inapplicability = published_policy.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = published_policy.nation_inapplicabilities.create!(nation: Nation.scotland)

    get :show, id: published_policy.document_identity

    assert_select "#inapplicable_nations" do
      assert_select "p", "This policy does not apply to Northern Ireland and Scotland."
      assert_select_object northern_ireland_inapplicability do
        assert_select "a[href='http://northern-ireland.com/']"
      end
      assert_select_object scotland_inapplicability, count: 0
    end
  end

  test "should explain that policy applies to the whole of the UK" do
    published_policy = create(:published_policy)

    get :show, id: published_policy.document_identity

    assert_select "#inapplicable_nations" do
      assert_select "p", "This policy applies to the whole of the UK."
    end
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