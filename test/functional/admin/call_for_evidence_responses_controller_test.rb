require "test_helper"

class Admin::CallForEvidenceResponsesControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as :writer
    @current_user.permissions << "Preview design system"
    @current_user.permissions << User::Permissions::PREVIEW_CALL_FOR_EVIDENCE
    @call_for_evidence = create(:draft_call_for_evidence, opening_at: 2.days.ago, closing_at: 1.day.ago)
  end

  test "Actions are unavailable if call_for_evidence is unmodifiable" do
    edition = create(:published_call_for_evidence)

    get :show, params: { call_for_evidence_id: edition, type: "CallForEvidenceOutcome" }
    assert_response :redirect
  end

  test "Access is forbidden to users who do not have access to the call_for_evidence" do
    login_as :world_editor
    get :show, params: { call_for_evidence_id: @call_for_evidence, type: "CallForEvidenceOutcome" }
    assert_response :forbidden
  end

  view_test "GET :show renders a form for outcome when one does not exist" do
    get :show, params: { call_for_evidence_id: @call_for_evidence, type: "CallForEvidenceOutcome" }

    assert_response :success
    assert_select "textarea[name='call_for_evidence_outcome[summary]']"
  end

  view_test "GET :show when call_for_evidence has an outcome shows the outcome details and includes an edit link" do
    create_outcome
    get :show, params: { call_for_evidence_id: @call_for_evidence, type: "CallForEvidenceOutcome" }

    assert_response :success
    assert_select "p", text: "A summary of the outcome"
    assert_select "a", text: "Edit Outcome"
  end

  test "POST :create with valid outcome params saves the outcome and redirects" do
    post :create, params: { call_for_evidence_id: @call_for_evidence, call_for_evidence_outcome: { summary: "Outcome summary", published_on: Time.zone.today }, type: "CallForEvidenceOutcome" }

    assert_response :redirect
    assert outcome = @call_for_evidence.outcome
    assert_equal "Outcome summary", outcome.summary
  end

  view_test "POST :create with invalid params re-renders the form" do
    post :create, params: { call_for_evidence_id: @call_for_evidence, call_for_evidence_outcome: { summary: "", published_on: Time.zone.today }, type: "CallForEvidenceOutcome" }

    assert_response :success
    assert_select "textarea[name='call_for_evidence_outcome[summary]']"
  end

  view_test "GET :edit renders the edit form for an outcome" do
    outcome = create_outcome
    get :edit, params: { call_for_evidence_id: @call_for_evidence, type: "CallForEvidenceOutcome" }
    assert_select "textarea[name='call_for_evidence_outcome[summary]']", text: outcome.summary
  end

  test "PUT :update with valid outcome params saves the changes to the outcome" do
    outcome = create_outcome
    put :update, params: { call_for_evidence_id: @call_for_evidence, call_for_evidence_outcome: { summary: "New summary", published_on: Time.zone.today }, type: "CallForEvidenceOutcome" }
    assert_response :redirect
    assert_equal "New summary", outcome.reload.summary
  end

private

  def create_outcome
    create(:call_for_evidence_outcome, summary: "A summary of the outcome", call_for_evidence: @call_for_evidence)
  end
end
