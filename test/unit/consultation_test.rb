require "test_helper"

class ConsultationTest < ActiveSupport::TestCase
  include DocumentBehaviour

  should_be_attachable
  should_allow_inline_attachments

  test "should not be valid without an opening on date" do
    consultation = build(:consultation, opening_on: nil)
    refute consultation.valid?
  end

  test "should not be valid without a closing on date" do
    consultation = build(:consultation, closing_on: nil)
    refute consultation.valid?
  end

  test "should not be valid if the opening date is after the closing date" do
    consultation = build(:consultation, opening_on: 1.day.ago, closing_on: 2.days.ago)
    refute consultation.valid?
  end

  test "should build a draft copy of the existing consultation with inapplicable nations" do
    published_consultation = create(:published_consultation, nation_inapplicabilities_attributes: [
      {nation: Nation.wales, alternative_url: "http://wales.gov.uk"},
      {nation: Nation.scotland, alternative_url: "http://scot.gov.uk"}]
    )

    draft_consultation = published_consultation.create_draft(create(:policy_writer))

    assert_equal published_consultation.inapplicable_nations, draft_consultation.inapplicable_nations
    assert_equal "http://wales.gov.uk", draft_consultation.nation_inapplicabilities.find_by_nation_id(Nation.wales.id).alternative_url
    assert_equal "http://scot.gov.uk", draft_consultation.nation_inapplicabilities.find_by_nation_id(Nation.scotland.id).alternative_url
  end

  test "#published_consultation_response provides access to the published response" do
    consultation = create(:published_consultation)
    consultation_response = create(:published_consultation_response, consultation: consultation)
    assert_equal consultation_response, consultation.published_consultation_response
  end

  test "#published_consultation_response excludes draft responses" do
    consultation = create(:published_consultation)
    consultation_response = create(:draft_consultation_response, consultation: consultation)
    assert_nil consultation.published_consultation_response
  end

  test "#latest_consultation_response provides access to the latest consultation response" do
    consultation = create(:published_consultation)
    older_response = create(:published_consultation_response, consultation: consultation)
    newer_response = older_response.create_draft(create(:policy_writer))
    assert_equal newer_response, consultation.latest_consultation_response
  end

  test "#latest_consultation_response includes draft responses" do
    consultation = create(:published_consultation)
    consultation_response = create(:draft_consultation_response, consultation: consultation)
    assert_equal consultation_response, consultation.latest_consultation_response
  end

  test "#latest_consultation_response excludes deleted editions" do
    consultation = create(:published_consultation)
    original_edition = create(:published_consultation_response, consultation: consultation)
    new_draft = original_edition.create_draft(create(:policy_writer))
    new_draft.delete!
    assert_equal original_edition, consultation.latest_consultation_response
  end

  test ".closed includes consultations closing in the past" do
    closed_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)

    assert_equal 1, Consultation.closed.count
    assert_equal closed_consultation, Consultation.closed.first
  end

  test ".closed excludes consultations closing in the future" do
    open_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.from_now)

    assert_equal 0, Consultation.closed.count
  end

  test ".closed excludes consultations closing today" do
    open_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: Date.today)

    assert_equal 0, Consultation.closed.count
  end

  test ".open includes consultations closing in the future and opening in the past" do
    open_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.from_now)

    assert_equal 1, Consultation.open.count
    assert_equal open_consultation, Consultation.open.first
  end

  test ".open includes consultations closing today and opening in the past" do
    open_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: Date.today)

    assert_equal 1, Consultation.open.count
    assert_equal open_consultation, Consultation.open.first
  end

  test ".open excludes consultations opening in the future" do
    upcoming_consultation = create(:consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now)

    assert_equal 0, Consultation.open.count
  end

  test ".open excludes consultations closing in the past" do
    closed_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)

    assert_equal 0, Consultation.open.count
  end

  test ".upcoming includes consultations opening in the future" do
    upcoming_consultation = create(:consultation, opening_on: 1.day.from_now, closing_on: 2.days.from_now)

    assert_equal 1, Consultation.upcoming.count
    assert_equal upcoming_consultation, Consultation.upcoming.first
  end

  test ".upcoming excludes consultations opening in the past" do
    open_consultation = create(:consultation, opening_on: 1.day.ago, closing_on: 1.day.from_now)
    closed_consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)

    assert_equal 0, Consultation.upcoming.count
  end

  test "should have last significant change on first published date for unopen consultation" do
    consultation = create(:published_consultation, first_published_at: 1.day.ago, opening_on: 1.day.from_now, closing_on: 2.days.from_now)
    assert_equal 1.day.ago.to_date, consultation.last_significantly_changed_on
  end

  test "should have last significant change on opening date for open consultation" do
    consultation = create(:published_consultation, first_published_at: 2.days.ago, opening_on: 1.day.ago, closing_on: 1.day.from_now)
    assert_equal 1.day.ago.to_date, consultation.last_significantly_changed_on
  end

  test "should have last significant change on closing date for closed consultation" do
    consultation = create(:published_consultation, first_published_at: 3.days.ago, opening_on: 2.days.ago, closing_on: 1.day.ago)
    assert_equal 1.day.ago.to_date, consultation.last_significantly_changed_on
  end

  test "should have last significant change on respone first published date for consultation with response" do
    consultation = create(:published_consultation, first_published_at: 4.days.ago, opening_on: 3.days.ago, closing_on: 2.day.ago)
    create(:published_consultation_response, consultation: consultation, first_published_at: 1.day.ago)
    assert_equal 1.day.ago.to_date, consultation.last_significantly_changed_on
  end

  test "should destroy associated consultation participation when destroyed" do
    consultation_participation = create(:consultation_participation, link_url: "http://example.com", link_text: "Respond here")
    consultation = create(:consultation, consultation_participation: consultation_participation)
    consultation.destroy
    assert_nil ConsultationParticipation.find_by_id(consultation_participation.id)
  end
end
