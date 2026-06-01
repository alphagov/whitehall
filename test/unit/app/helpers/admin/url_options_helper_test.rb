require "test_helper"

class Admin::UrlOptionsHelperTest < ActionView::TestCase
  test "#attachment_preview_options returns an empty hash when the attachable is a published Edition" do
    edition = create(:published_publication)
    assert_equal({}, attachment_preview_options(edition))
  end

  test "#attachment_preview_options returns an empty hash when the attachable is a withdrawn Edition" do
    edition = create(:withdrawn_publication)
    assert_equal({}, attachment_preview_options(edition))
  end

  test "#attachment_preview_options returns an empty hash when the attachable is a superseded Edition" do
    edition = create(:superseded_publication)
    assert_equal({}, attachment_preview_options(edition))
  end

  test "#attachment_preview_options returns an empty hash when the attachable is an unpublished Edition" do
    edition = create(:unpublished_publication)
    assert_equal({}, attachment_preview_options(edition))
  end

  test "#attachment_preview_options returns preview and cachebust options when the attachable is a draft Edition" do
    edition = create(:draft_publication)
    travel_to(Time.zone.local(2026, 5, 27, 12, 0, 0)) do
      cachebust = Time.zone.now.getutc.to_i
      assert_equal({ preview: true, cachebust: }, attachment_preview_options(edition))
    end
  end

  test "#attachment_preview_options returns an empty hash when the attachable is a ConsultationResponse whose consultation is published" do
    consultation = create(:published_consultation)
    response = build(:consultation_outcome, consultation:)
    assert_equal({}, attachment_preview_options(response))
  end

  test "#attachment_preview_options returns preview and cachebust options when the attachable is a ConsultationResponse whose consultation is a draft" do
    consultation = create(:draft_consultation)
    response = build(:consultation_outcome, consultation:)
    travel_to(Time.zone.local(2026, 5, 27, 12, 0, 0)) do
      cachebust = Time.zone.now.getutc.to_i
      assert_equal({ preview: true, cachebust: }, attachment_preview_options(response))
    end
  end

  test "#attachment_preview_options returns an empty hash when the attachable is a CallForEvidenceResponse whose call for evidence is published" do
    call_for_evidence = create(:published_call_for_evidence)
    response = build(:call_for_evidence_outcome, call_for_evidence:)
    assert_equal({}, attachment_preview_options(response))
  end

  test "#attachment_preview_options returns preview and cachebust options when the attachable is a CallForEvidenceResponse whose call for evidence is a draft" do
    call_for_evidence = create(:draft_call_for_evidence)
    response = build(:call_for_evidence_outcome, call_for_evidence:)
    travel_to(Time.zone.local(2026, 5, 27, 12, 0, 0)) do
      cachebust = Time.zone.now.getutc.to_i
      assert_equal({ preview: true, cachebust: }, attachment_preview_options(response))
    end
  end

  test "#attachment_preview_options returns preview and cachebust options when the attachable is a PolicyGroup" do
    policy_group = create(:policy_group)
    travel_to(Time.zone.local(2026, 5, 27, 12, 0, 0)) do
      cachebust = Time.zone.now.getutc.to_i
      assert_equal({ preview: true, cachebust: }, attachment_preview_options(policy_group))
    end
  end
end
