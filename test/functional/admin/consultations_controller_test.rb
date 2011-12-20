require 'test_helper'

class Admin::ConsultationsControllerTest < ActionController::TestCase

  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :consultation
  should_allow_creating_of :consultation
  should_allow_editing_of :consultation

  should_allow_featuring_of :consultation
  should_allow_organisations_for :consultation
  should_allow_ministerial_roles_for :consultation
  should_allow_attachments_for :consultation
  should_be_rejectable :consultation
  should_be_force_publishable :consultation
  should_be_able_to_delete_a_document :consultation
  should_link_to_public_version_when_published :consultation
  should_not_link_to_public_version_when_not_published :consultation
  should_prevent_modification_of_unmodifiable :consultation

  test 'new displays consultation fields' do
    get :new

    assert_select "form#document_new" do
      assert_select "textarea[name='document[summary]']"
      assert_select "select[name*='document[opening_on']", count: 3
      assert_select "select[name*='document[closing_on']", count: 3
    end
  end

  test "create should create a new consultation" do
    attributes = attributes_for(:consultation)

    post :create, document: attributes

    consultation = Consultation.last
    assert_equal attributes[:summary], consultation.summary
    assert_equal attributes[:opening_on].to_date, consultation.opening_on
    assert_equal attributes[:closing_on].to_date, consultation.closing_on
  end

  test "show renders the summary" do
    draft_consultation = create(:draft_consultation, summary: "a-simple-summary")
    get :show, id: draft_consultation
    assert_select ".summary", text: "a-simple-summary"
  end

  test "show displays consultation opening date" do
    consultation = create(:consultation, opening_on: Date.new(2011, 10, 10))
    get :show, id: consultation
    assert_select '.opening_on', text: 'Opened on October 10th, 2011'
  end

  test "show displays consultation closing date" do
    consultation = create(:consultation, opening_on: Date.new(2010, 01, 01), closing_on: Date.new(2011, 01, 01))
    get :show, id: consultation
    assert_select '.closing_on', text: 'Closed on January 1st, 2011'
  end

  test "show displays related policies" do
    policy = create(:policy)
    consultation = create(:consultation, related_policies: [policy])
    get :show, id: consultation
    assert_select_object policy
  end

  test "edit displays consultation fields" do
    consultation = create(:consultation)

    get :edit, id: consultation

    assert_select "form#document_edit" do
      assert_select "textarea[name='document[summary]']"
      assert_select "select[name*='document[opening_on']", count: 3
      assert_select "select[name*='document[closing_on']", count: 3
    end
  end

  test "update should save modified consultation attributes" do
    consultation = create(:consultation)

    put :update, id: consultation, document: {
      summary: "new-summary",
      opening_on: 1.day.ago,
      closing_on: 50.days.from_now
    }

    consultation.reload
    assert_equal "new-summary", consultation.summary
    assert_equal 1.day.ago.to_date, consultation.opening_on
    assert_equal 50.days.from_now.to_date, consultation.closing_on
  end
end