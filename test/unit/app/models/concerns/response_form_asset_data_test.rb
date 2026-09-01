require "test_helper"

class ResponseFormAssetDataTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  test "#deleted? returns false" do
    assert_not build(:consultation_response_form_data).deleted?
  end

  test "#replaced? returns false" do
    assert_not build(:consultation_response_form_data).replaced?
  end

  test "#draft? returns true when the attachable is not publicly visible" do
    consultation = build(:consultation, state: "draft")
    consultation_participation = build(:consultation_participation, consultation:)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = build(:consultation_response_form_data, consultation_response_form:)

    assert consultation_response_form_data.draft?
  end

  test "#draft? returns false when the attachable is publicly visible" do
    consultation = build(:consultation, state: "published")
    consultation_participation = build(:consultation_participation, consultation:)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = build(:consultation_response_form_data, consultation_response_form:)

    assert_not consultation_response_form_data.draft?
  end

  test "#access_limitation_organisation_ids returns an empty array when the attachable is not access limited" do
    assert_empty build(:consultation_response_form_data).access_limitation_organisation_ids
  end

  test "#access_limitation_organisation_ids returns the attachable's access limiting organisations" do
    consultation = build(:consultation)
    consultation.stubs(:access_limited?).returns(true)
    consultation.stubs(:access_limited_object).returns(consultation)
    consultation_participation = build(:consultation_participation, consultation:)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = build(:consultation_response_form_data, consultation_response_form:)

    AssetManagerAccessLimitation.expects(:for).with(consultation, :organisations).returns(%w[content-id-1])

    assert_equal %w[content-id-1], consultation_response_form_data.access_limitation_organisation_ids
  end

  test "#access_limitation_individual_ids returns an empty array when the attachable is not access limited" do
    assert_empty build(:consultation_response_form_data).access_limitation_individual_ids
  end

  test "#attachable_url returns draft url for pre-publication attachable" do
    consultation = create(:draft_consultation)
    consultation_participation = create(:consultation_participation, consultation:)
    consultation_response_form = create(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = consultation_response_form.consultation_response_form_data

    assert_equal consultation.public_url(draft: true), consultation_response_form_data.attachable_url
  end

  test "#attachable_url returns live url for published attachable" do
    consultation = create(:published_consultation)
    consultation_participation = create(:consultation_participation, consultation:)
    consultation_response_form = create(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = consultation_response_form.consultation_response_form_data

    assert_equal consultation.public_url, consultation_response_form_data.attachable_url
  end

  test "#attachable_url returns nil when there is no persisted attachable" do
    assert_nil build(:consultation_response_form_data).attachable_url
  end

  test "#auth_bypass_ids returns the attachable's auth_bypass_id" do
    auth_bypass_id = "86385d6a-f918-4c93-96bf-087218a48ced"
    consultation = Consultation.new(id: 1, auth_bypass_id:)
    consultation_participation = build(:consultation_participation, consultation:)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = build(:consultation_response_form_data, consultation_response_form:)

    assert_equal [auth_bypass_id], consultation_response_form_data.auth_bypass_ids
  end

  test "#auth_bypass_ids returns an empty array when the attachable has no auth_bypass_id" do
    assert_empty build(:consultation_response_form_data).auth_bypass_ids
  end

  test "#last_attachable returns the attachable" do
    consultation = build(:consultation)
    consultation_participation = build(:consultation_participation, consultation:)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = build(:consultation_response_form_data, consultation_response_form:)

    assert_equal consultation, consultation_response_form_data.last_attachable
  end

  test "#needs_publishing? returns true when the attachable is publicly visible" do
    consultation = build(:consultation, state: "published")
    consultation_participation = build(:consultation_participation, consultation:)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = build(:consultation_response_form_data, consultation_response_form:)

    assert consultation_response_form_data.needs_publishing?
  end

  test "#needs_publishing? returns false when the attachable is not publicly visible" do
    consultation = build(:consultation, state: "draft")
    consultation_participation = build(:consultation_participation, consultation:)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = build(:consultation_response_form_data, consultation_response_form:)

    assert_not consultation_response_form_data.needs_publishing?
  end
end
