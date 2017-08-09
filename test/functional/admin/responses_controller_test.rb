require 'test_helper'

class Admin::ResponsesControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as :writer
    @consultation = create(:draft_consultation, opening_at: 2.days.ago, closing_at: 1.day.ago)
  end

  test 'Actions are unavailable if consultation is unmodifiable' do
    edition = create(:published_consultation)

    get :show, params: { consultation_id: edition, type: 'ConsultationOutcome' }
    assert_response :redirect
  end

  test 'Access is forbidden to users who do not have access to the consultation' do
    login_as :world_editor
    get :show, params: { consultation_id: @consultation, type: 'ConsultationOutcome' }
    assert_response :forbidden
  end

  view_test "GET :show renders a form for outcome when one does not exist" do
    get :show, params: { consultation_id: @consultation, type: 'ConsultationOutcome' }

    assert_response :success
    assert_select "textarea[name='consultation_outcome[summary]']"
  end

  view_test "GET :show renders a form for feedback when one does not exist" do
    get :show, params: { consultation_id: @consultation, type: 'ConsultationPublicFeedback' }

    assert_response :success
    assert_select "textarea[name='consultation_public_feedback[summary]']"
  end

  view_test "GET :show when consultation has an outcome shows the outcome details and includes an edit link" do
    outcome = create_outcome
    get :show, params: { consultation_id: @consultation, type: 'ConsultationOutcome' }

    assert_response :success
    assert_select 'p', text: 'A summary of the outcome'
    assert_select 'a', text: 'Edit outcome'
  end

  view_test "GET :show when consultation has public feedback shows the feedback details and includes an edit link" do
    feedback = create_feedback
    get :show, params: { consultation_id: @consultation, type: 'ConsultationPublicFeedback' }

    assert_response :success
    assert_select 'p', text: 'A summary of the public feedback'
    assert_select 'a', text: 'Edit public feedback'
  end

  test "POST :create with valid outcome params saves the outcome and redirects" do
    post :create, params: { consultation_id: @consultation, consultation_outcome: { summary: 'Outcome summary', published_on: Date.today }, type: 'ConsultationOutcome' }

    assert_response :redirect
    assert outcome = @consultation.outcome
    assert_equal 'Outcome summary', outcome.summary
  end

  test "POST :create with valid feedback params saves the feedback and redirects" do
    post :create, params: { consultation_id: @consultation, consultation_public_feedback: { summary: 'Feedback summary', published_on: Date.today }, type: 'ConsultationPublicFeedback' }

    assert_response :redirect
    assert public_feedback = @consultation.public_feedback
    assert_equal 'Feedback summary', public_feedback.summary
  end

  view_test "POST :create with invalid params re-renders the form" do
    post :create, params: { consultation_id: @consultation, consultation_outcome: { summary: '', published_on: Date.today }, type: 'ConsultationOutcome' }

    assert_response :success
    assert_select "textarea[name='consultation_outcome[summary]']"
  end

  view_test "GET :edit renders the edit form for an outcome" do
    outcome = create_outcome
    get :edit, params: { consultation_id: @consultation, type: 'ConsultationOutcome' }
    assert_select "textarea[name='consultation_outcome[summary]']", text: outcome.summary
  end

  view_test "GET :edit renders the edit form for public feedback" do
    feedback = create_feedback
    get :edit, params: { consultation_id: @consultation, type: 'ConsultationPublicFeedback' }
    assert_select "textarea[name='consultation_public_feedback[summary]']", text: feedback.summary
  end

  test "PUT :update with valid outcome params saves the changes to the outcome" do
    outcome = create_outcome
    put :update, params: { consultation_id: @consultation, consultation_outcome: { summary: 'New summary', published_on: Date.today }, type: 'ConsultationOutcome' }
    assert_response :redirect
    assert_equal 'New summary', outcome.reload.summary
  end

  test "PUT :update with valid feedback params saves the changes to the feedback" do
    feedback = create_feedback
    put :update, params: { consultation_id: @consultation, consultation_public_feedback: { summary: 'New summary', published_on: Date.today }, type: 'ConsultationPublicFeedback' }
    assert_response :redirect
    assert_equal 'New summary', feedback.reload.summary
  end

  private

  def create_outcome
    create(:consultation_outcome, summary: 'A summary of the outcome', consultation: @consultation)
  end

  def create_feedback
    create(:consultation_public_feedback, summary: 'A summary of the public feedback', consultation: @consultation)
  end
end
