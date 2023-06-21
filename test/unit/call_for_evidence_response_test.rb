require "test_helper"

class CallForEvidenceResponseTest < ActiveSupport::TestCase
  test "responses without a summary are only valid if they have attachments" do
    response = build(:call_for_evidence_outcome, summary: nil)
    assert_not response.valid?

    response.attachments << build(:file_attachment)
    assert response.valid?, response.errors.full_messages.inspect
  end

  test "should return the alternative_format_contact_email of the call for evidence" do
    call_for_evidence = build(:call_for_evidence)
    call_for_evidence.stubs(alternative_format_contact_email: "alternative format contact email")
    response = build(:call_for_evidence_outcome, call_for_evidence:)

    assert_equal call_for_evidence.alternative_format_contact_email, response.alternative_format_contact_email
  end

  test "is publicly visible if its call for evidence is publicly visible" do
    call_for_evidence = build(:call_for_evidence)
    call_for_evidence.stubs(:publicly_visible?).returns(true)
    response = build(:call_for_evidence_outcome, call_for_evidence:)

    assert response.publicly_visible?
  end

  test "is not publicly visible if its call for evidence is not publicly visible" do
    call_for_evidence = build(:call_for_evidence)
    call_for_evidence.stubs(:publicly_visible?).returns(false)
    response = build(:call_for_evidence_outcome, call_for_evidence:)

    assert_not response.publicly_visible?
  end

  test "is not publicly visible if its call for evidence is nil" do
    response = build(:call_for_evidence_outcome, call_for_evidence: nil)

    assert_not response.publicly_visible?
  end

  test "is unpublished if its call for evidence is unpublished" do
    call_for_evidence = build(:call_for_evidence)
    call_for_evidence.stubs(:unpublished?).returns(true)
    response = build(:call_for_evidence_outcome, call_for_evidence:)

    assert response.unpublished?
  end

  test "is not unpublished if its call for evidence is not unpublished" do
    call_for_evidence = build(:call_for_evidence)
    call_for_evidence.stubs(:unpublished?).returns(false)
    response = build(:call_for_evidence_outcome, call_for_evidence:)

    assert_not response.unpublished?
  end

  test "is not unpublished if its call for evidence is nil" do
    response = build(:call_for_evidence_outcome, call_for_evidence: nil)

    assert_not response.unpublished?
  end

  test "returns unpublished edition from its call for evidence" do
    call_for_evidence = build(:call_for_evidence)
    call_for_evidence.stubs(:unpublished_edition).returns(call_for_evidence)
    response = build(:call_for_evidence_outcome, call_for_evidence:)

    assert_equal call_for_evidence, response.unpublished_edition
  end

  test "returns no unpublished edition if its call for evidence is nil" do
    response = build(:call_for_evidence_outcome, call_for_evidence: nil)

    assert_nil response.unpublished_edition
  end

  test "is accessible to user if call for evidence is accessible to user" do
    user = build(:user)
    call_for_evidence = build(:call_for_evidence)
    call_for_evidence.stubs(:accessible_to?).with(user).returns(true)
    response = build(:call_for_evidence_outcome, call_for_evidence:)

    assert response.accessible_to?(user)
  end

  test "is not accessible to user if call for evidence is not accessible to user" do
    user = build(:user)
    call_for_evidence = build(:call_for_evidence)
    call_for_evidence.stubs(:accessible_to?).with(user).returns(false)
    response = build(:call_for_evidence_outcome, call_for_evidence:)

    assert_not response.accessible_to?(user)
  end

  test "is not accessible to user if call for evidence is nil" do
    user = build(:user)
    response = build(:call_for_evidence_outcome, call_for_evidence: nil)

    assert_not response.accessible_to?(user)
  end

  test "is access limited if its call for evidence is access limited" do
    call_for_evidence = build(:call_for_evidence)
    call_for_evidence.stubs(:access_limited?).returns(true)
    response = build(:call_for_evidence_outcome, call_for_evidence:)

    assert response.access_limited?
  end

  test "is not access limited if its call for evidence is not access limited" do
    call_for_evidence = build(:call_for_evidence)
    call_for_evidence.stubs(:access_limited?).returns(false)
    response = build(:call_for_evidence_outcome, call_for_evidence:)

    assert_not response.access_limited?
  end

  test "is not access limited if its call for evidence is nil" do
    response = build(:call_for_evidence_outcome, call_for_evidence: nil)

    assert_not response.access_limited?
  end

  test "returns call for evidence as its access limited object" do
    call_for_evidence = build(:call_for_evidence)
    response = build(:call_for_evidence_outcome, call_for_evidence:)

    assert_equal call_for_evidence, response.access_limited_object
  end

  test "returns its call for evidence content_id" do
    call_for_evidence = create(:call_for_evidence)
    response = build(:call_for_evidence_outcome, call_for_evidence:)

    assert_equal call_for_evidence.content_id, response.content_id
  end

  test "returns no access limited object if its call for evidence is nil" do
    response = build(:call_for_evidence_outcome, call_for_evidence: nil)

    assert_nil response.access_limited_object
  end

  test "returns call for evidence organisations as its organisations" do
    organisations = create_list(:organisation, 2)
    call_for_evidence = create(:call_for_evidence, organisations:)
    response = build(:call_for_evidence_outcome, call_for_evidence:)

    assert_equal organisations, response.organisations
  end

  test "returns no organisations if call for evidence is nil" do
    response = build(:call_for_evidence_outcome, call_for_evidence: nil)

    assert_equal [], response.organisations
  end
end
