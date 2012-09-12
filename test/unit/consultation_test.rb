require "test_helper"

class ConsultationTest < EditionTestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_be_attachable
  should_allow_inline_attachments
  should_allow_a_summary_to_be_written
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

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
    published_response = consultation.create_response!
    published_response.stubs(:published?).returns(true)
    assert_equal published_response, consultation.published_consultation_response
  end

  test "#published_consultation_response returns nil if there is no response for this consultation" do
    consultation = create(:published_consultation)
    assert_nil consultation.published_consultation_response
  end

  test "#published_consultation_response returns nil if the response isn't published" do
    consultation = create(:published_consultation)
    published_response = consultation.create_response!
    published_response.stubs(:published?).returns(false)
    assert_nil consultation.published_consultation_response
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

  test "should have last significant change on response first published date for consultation with response" do
    consultation = create(:published_consultation, first_published_at: 4.days.ago, opening_on: 3.days.ago, closing_on: 2.day.ago)
    response = consultation.create_response!
    response.stubs(:published?).returns(true)
    response.stubs(:published_on).returns(1.day.ago)
    assert_equal 1.day.ago.to_date, consultation.last_significantly_changed_on
  end

  test "should not create a participation if all participation fields are blank" do
    attributes = {link_url: nil, consultation_response_form_attributes: {title: nil, file: nil}}
    consultation = create(:consultation, consultation_participation_attributes: attributes)
    assert consultation.consultation_participation.blank?
  end

  test "should preserve original participation when creating new edition" do
    consultation_participation = create(:consultation_participation, link_url: "http://example.com")
    consultation = create(:published_consultation, consultation_participation: consultation_participation)

    new_draft = consultation.create_draft(create(:policy_writer))

    assert_equal new_draft.consultation_participation.link_url, consultation_participation.link_url, "link attribute should be copied"
  end

  test "should destroy associated consultation participation when destroyed" do
    consultation_participation = create(:consultation_participation, link_url: "http://example.com")
    consultation = create(:consultation, consultation_participation: consultation_participation)
    consultation.destroy
    assert_nil ConsultationParticipation.find_by_id(consultation_participation.id)
  end

  test "should accept nested attributes for the consultation response" do
    consultation = build(:consultation)
    consultation.response_attributes = {
      summary: 'response-summary'
    }
    consultation.save!

    assert_equal 'response-summary', consultation.response.summary
  end

  test "should not build an empty consultation response if the attributes are blank" do
    consultation = build(:consultation)
    consultation.response_attributes = {
      summary: nil
    }
    consultation.save!

    assert_nil consultation.response
  end

  test "should not build an empty consultation response if the response attachment attributes are all blank" do
    consultation = build(:consultation)
    consultation.response_attributes = {
      summary: '',
      consultation_response_attachments_attributes: {
        '0' => {
          attachment_attributes: {
            title: '',
            file: ''
          }
        }
      }
    }
    consultation.save!

    assert_nil consultation.response
  end

  test "should destroy the consultation response when the consultation is destroyed" do
    consultation = create(:consultation)
    response = consultation.create_response!

    consultation.destroy

    assert_nil Response.find_by_id(response.id)
  end

  test "should copy the response summary and link to the original attachments when creating a new draft" do
    consultation = create(:published_consultation)
    response = consultation.create_response! summary: 'response-summary'
    attachment = response.attachments.create! title: 'attachment-title', file: fixture_file_upload('greenpaper.pdf')

    new_draft = consultation.create_draft(build(:user))
    new_draft.reload

    assert_equal 'response-summary', new_draft.response.summary
    assert_not_equal response, new_draft.response
    assert_equal 1, new_draft.response.attachments.length
    assert_equal 'attachment-title', new_draft.response.attachments.first.title
    assert_equal attachment, new_draft.response.attachments.first
  end

  test "should report that the response has not been published if the consultation is still open" do
    consultation = create(:consultation, opening_on: 1.day.ago, closing_on: 1.month.from_now)

    refute consultation.response_published?
  end

  test "should report that the response has not been published if the consultation is closed and there is no response" do
    consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)

    refute consultation.response_published?
  end

  test "should report that the response has been published if the consultation is closed and the response is published" do
    consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)
    response = consultation.create_response! summary: 'response-summary'
    response.stubs(:published?).returns(true)

    assert consultation.response_published?
  end

  test "should return the published_on date of the response" do
    today = Date.today
    consultation = create(:consultation)
    response = consultation.create_response!
    response.stubs(:published_on).returns(today)

    assert_equal today, consultation.response_published_on
  end
end
