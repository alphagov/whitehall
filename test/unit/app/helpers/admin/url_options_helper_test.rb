require "test_helper"

class Admin::UrlOptionsHelperTest < ActionView::TestCase
  test "#attachable_post_publication? returns true when the attachable is a published Edition" do
    edition = create(:published_publication)
    assert attachable_post_publication?(edition)
  end

  test "#attachable_post_publication? returns true when the attachable is a withdrawn Edition" do
    edition = create(:withdrawn_publication)
    assert attachable_post_publication?(edition)
  end

  test "#attachable_post_publication? returns true when the attachable is a superseded Edition" do
    edition = create(:superseded_publication)
    assert attachable_post_publication?(edition)
  end

  test "#attachable_post_publication? returns true when the attachable is an unpublished Edition" do
    edition = create(:unpublished_publication)
    assert attachable_post_publication?(edition)
  end

  test "#attachable_post_publication? returns false when the attachable is a draft Edition" do
    edition = create(:draft_publication)
    assert_not attachable_post_publication?(edition)
  end

  test "#attachable_post_publication? returns true when the attachable is a ConsultationResponse whose consultation is published" do
    consultation = create(:published_consultation)
    response = build(:consultation_outcome, consultation:)
    assert attachable_post_publication?(response)
  end

  test "#attachable_post_publication? returns false when the attachable is a ConsultationResponse whose consultation is a draft" do
    consultation = create(:draft_consultation)
    response = build(:consultation_outcome, consultation:)
    assert_not attachable_post_publication?(response)
  end

  test "#attachable_post_publication? returns true when the attachable is a CallForEvidenceResponse whose call for evidence is published" do
    call_for_evidence = create(:published_call_for_evidence)
    response = build(:call_for_evidence_outcome, call_for_evidence:)
    assert attachable_post_publication?(response)
  end

  test "#attachable_post_publication? returns false when the attachable is a CallForEvidenceResponse whose call for evidence is a draft" do
    call_for_evidence = create(:draft_call_for_evidence)
    response = build(:call_for_evidence_outcome, call_for_evidence:)
    assert_not attachable_post_publication?(response)
  end

  test "#attachable_post_publication? returns false when the attachable is a PolicyGroup" do
    policy_group = create(:policy_group)
    assert_not attachable_post_publication?(policy_group)
  end
end
