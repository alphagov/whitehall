require 'test_helper'

class Admin::ResponsesControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as :policy_writer
    @consultation = create(:draft_consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)
  end

  test 'Actions are unavailable if consultation is unmodifiable' do
    edition = create(:published_consultation)

    get :show, consultation_id: edition, type: 'ConsultationOutcome'
    assert_response :redirect
  end

  test 'Access is forbidden to users who do not have access to the consultation' do
    login_as :world_editor
    get :show, consultation_id: @consultation
    assert_response :forbidden
  end

  view_test "GET :show for the outcome has a link for adding an outcome when one does not exist" do
    get :show, consultation_id: @consultation, type: 'ConsultationOutcome'

    assert_response :success
    assert_select 'a', text: 'Add an outcome'
  end

  view_test "GET :show when consultation has an outcome shows the outcome details and includes an edit link" do
    response = create_outcome
    get :show, consultation_id: @consultation, type: 'ConsultationOutcome'

    assert_response :success
    assert_select 'p', text: 'A summary of the outcome'
    assert_select 'a', text: 'Edit outcome'
  end

  view_test "GET :new renders an outcome form" do
    get :new, consultation_id: @consultation, type: 'ConsultationOutcome'

    assert_response :success
    assert_select "textarea[name='consultation_outcome[summary]']"
  end

  test "POST :create with valid outcome params saves the outcome and redirects" do
    post :create, consultation_id: @consultation, consultation_outcome: { summary: 'Outcome summary', published_on: Date.today }, type: 'ConsultationOutcome'

    assert_response :redirect
    assert outcome = @consultation.outcome
    assert_equal 'Outcome summary', outcome.summary
  end

  view_test "GET :edit renders the edit form for an outcome" do
    outcome = create_outcome
    get :edit, consultation_id: @consultation, type: 'ConsultationOutcome'
    assert_select "textarea[name='consultation_outcome[summary]']", text: outcome.summary
  end

  test "PUT :create with valid outcome params saves the changes to the outcome" do
    response = create_outcome
    put :update, consultation_id: @consultation, consultation_outcome: { summary: 'New summary', published_on: Date.today }
    assert_response :redirect
    assert_equal 'New summary', response.reload.summary
  end


  def create_outcome
    create(:consultation_outcome, summary: 'A summary of the outcome', consultation: @consultation)
  end
end
