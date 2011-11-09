require "test_helper"

class ConsultationsControllerTest < ActionController::TestCase

  should_render_a_list_of :consultations

  test 'show displays published consultations' do
    published_consultation = create(:published_consultation)
    get :show, id: published_consultation.document_identity
    assert_response :success
  end

  test 'show displays consultation opening date' do
    published_consultation = create(:published_consultation, opening_on: Date.new(2011, 10, 10))
    get :show, id: published_consultation.document_identity
    assert_select '.opening_on', text: 'Opened on October 10th, 2011'
  end

  test 'show displays consultation closing date' do
    published_consultation = create(:published_consultation, opening_on: Date.new(2010, 1, 1), closing_on: Date.new(2011, 01, 01))
    get :show, id: published_consultation.document_identity
    assert_select '.closing_on', text: 'Closed on January 1st, 2011'
  end

  test 'show displays consultation attachment' do
    consultation = create(:published_consultation, attachments: [create(:attachment)])
    get :show, id: consultation.document_identity
    assert_select '.attachment a', text: consultation.attachments.first.filename
  end

  test 'show displays related published policies' do
    published_policy = create(:published_policy)
    consultation = create(:published_consultation, documents_related_to: [published_policy])
    get :show, id: consultation.document_identity
    assert_select_object published_policy
  end

  test 'show doesn\'t display related unpublished policies' do
    draft_policy = create(:draft_policy)
    consultation = create(:published_consultation, documents_related_to: [draft_policy])
    get :show, id: consultation.document_identity
    assert_select_object draft_policy, count: 0
  end

  test "should show inapplicable nations" do
    published_consultation = create(:published_consultation)
    northern_ireland_inapplicability = published_consultation.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = published_consultation.nation_inapplicabilities.create!(nation: Nation.scotland)

    get :show, id: published_consultation.document_identity

    assert_select "#inapplicable_nations" do
      assert_select "p", "This consultation does not apply to Northern Ireland and Scotland."
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
