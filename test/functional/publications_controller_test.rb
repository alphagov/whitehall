require "test_helper"

class PublicationsControllerTest < ActionController::TestCase
  test 'show displays published publications' do
    published_publication = create(:published_publication)
    get :show, id: published_publication.document_identity
    assert_response :success
  end

  test 'show displays related published policies' do
    published_policy = create(:published_policy)
    publication = create(:published_publication, documents_related_to: [published_policy])
    get :show, id: publication.document_identity
    assert_select_object published_policy
  end

  test 'show doesn\'t display related but unpublished policies' do
    draft_policy = create(:draft_policy)
    publication = create(:published_publication, documents_related_to: [draft_policy])
    get :show, id: publication.document_identity
    assert_select_object draft_policy, count: 0
  end

  test "should show inapplicable nations" do
    published_publication = create(:published_publication)
    northern_ireland_inapplicability = published_publication.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = published_publication.nation_inapplicabilities.create!(nation: Nation.scotland)

    get :show, id: published_publication.document_identity

    assert_select "#inapplicable_nations" do
      assert_select "p", "This publication does not apply to Northern Ireland and Scotland."
      assert_select_object northern_ireland_inapplicability do
        assert_select "a[href='http://northern-ireland.com/']"
      end
      assert_select_object scotland_inapplicability, count: 0
    end
  end

  test "should explain that consultation applies to the whole of the UK" do
    published_consultation = create(:published_consultation)

    get :show, id: published_consultation.document_identity

    assert_select "#inapplicable_nations" do
      assert_select "p", "This consultation applies to the whole of the UK."
    end
  end
end
