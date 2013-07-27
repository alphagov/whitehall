require "test_helper"

class ConsultationTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_be_attachable
  should_not_allow_inline_attachments
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note
  should_allow_html_version

  [:imported, :deleted].each do |state|
    test "#{state} editions are valid without an opening on date" do
      edition = build(:consultation, state: state, opening_on: nil)
      assert edition.valid?
    end

    test "#{state} editions are valid without a closing on date" do
      edition = build(:consultation, state: state, closing_on: nil)
      assert edition.valid?
    end

    test "#{state} consultations with a blank opening on date have no first_public_at" do
      edition = build(:consultation, state: state, opening_on: nil)
      assert_nil edition.first_public_at
    end

    test "#{state} consultations with a blank opening on date have no first_published_date" do
      edition = build(:consultation, state: state, opening_on: nil)
      assert_nil edition.first_published_date
    end

    test "#{state} consultations with a blank opening on date are not open?, they are not_yet_open?" do
      edition = build(:consultation, state: state, opening_on: nil)
      refute edition.open?
      assert edition.not_yet_open?
    end

    test "#{state} consultations with a blank closing on date are closed?" do
      edition = build(:consultation, state: state, closing_on: nil)
      assert edition.closed?
    end
  end

  [:draft, :scheduled, :published, :submitted, :rejected].each do |state|
    test "#{state} editions are not valid without an opening on date" do
      edition = build(:consultation, state: state, opening_on: nil)
      refute edition.valid?
    end

    test "#{state} editions are not valid without a closing on date" do
      edition = build(:consultation, state: state, closing_on: nil)
      refute edition.valid?
    end
  end

  test "should be invalid if the opening date is after the closing date" do
    consultation = build(:consultation, opening_on: 1.day.ago, closing_on: 2.days.ago)
    refute consultation.valid?
  end

  test "should be invalid if publication type not set to consultation" do
    consultation = build(:consultation)
    consultation.publication_type_id = PublicationType::PolicyPaper
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

  test ".closed_since only includes consultations closed on or after the specified date" do
    closed_three_days_ago = create(:consultation, opening_on: 1.month.ago, closing_on: 3.days.ago)
    closed_two_days_ago = create(:consultation, opening_on: 1.month.ago, closing_on: 2.days.ago)
    open = create(:consultation, opening_on: 1.month.ago, closing_on: 1.day.from_now)

    assert_same_elements [], Consultation.closed_since(1.days.ago)
    assert_same_elements [closed_two_days_ago], Consultation.closed_since(2.days.ago)
    assert_same_elements [closed_two_days_ago, closed_three_days_ago], Consultation.closed_since(3.days.ago)
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

  test "should destroy the consultation response when the consultation is destroyed" do
    consultation = create(:consultation)
    response = create(:response, consultation: consultation)

    consultation.destroy

    assert_nil Response.find_by_id(response.id)
  end

  test "should copy the response summary and link to the original attachments when creating a new draft" do
    consultation = create(:published_consultation)
    response = create(:response, consultation: consultation)
    attachment = response.attachments.create! title: 'attachment-title', attachment_data_attributes: { file: fixture_file_upload('greenpaper.pdf') }

    new_draft = consultation.create_draft(build(:user))
    new_draft.reload

    assert_equal response.summary, new_draft.response.summary
    assert_not_equal response, new_draft.response
    assert_equal 1, new_draft.response.attachments.length
    assert_equal 'attachment-title', new_draft.response.attachments.first.title
    assert_not_equal attachment, new_draft.response.attachments.first
    assert_equal attachment.attachment_data, new_draft.response.attachments.first.attachment_data
  end

  test "should report that the response has not been published if the consultation is still open" do
    consultation = create(:consultation, opening_on: 1.day.ago, closing_on: 1.month.from_now)

    refute consultation.response_published?
  end

  test "should report that the response has not been published if the consultation is closed and there is no response" do
    consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)

    refute consultation.response_published?
  end

  test "should report that the response has been published if the consultation is closed" do
    consultation = create(:consultation, opening_on: 2.days.ago, closing_on: 1.day.ago)
    response = create(:response, consultation: consultation)

    assert consultation.response_published?
  end

  test "should return the published_on date of the response" do
    today = Date.today
    consultation = create(:consultation)
    response = create(:response, consultation: consultation)
    response.stubs(:published_on).returns(today)

    assert_equal today, consultation.response_published_on
  end

  test "first published date is the date of consultation opening" do
    consultation = create(:published_consultation, opening_on: 4.days.ago)

    assert_equal 4.days.ago.to_date, consultation.first_published_date
  end

  test "make_public_at should not set first_published_at" do
    consultation = build(:consultation, first_published_at: nil)
    consultation.make_public_at(2.days.ago)
    refute consultation.first_published_at
  end

  test "display_type when not yet open" do
    consultation = build(:consultation, opening_on: Date.new(2011, 11, 25), closing_on: Date.new(2012, 2, 1))
    assert_equal "Consultation", consultation.display_type
  end

  test "display_type when open" do
    consultation = build(:consultation, opening_on: Date.new(2011, 11, 1), closing_on: Date.new(2011, 12, 1))
    assert_equal "Open consultation", consultation.display_type
  end

  test "display_type when closed" do
    consultation = build(:consultation, opening_on: Date.new(2011, 7, 1), closing_on: Date.new(2011, 9, 1))
    assert_equal "Closed consultation", consultation.display_type
  end

  test "display_type when response published" do
    consultation = build(:consultation, opening_on: Date.new(2011, 5, 1), closing_on: Date.new(2011, 7, 1))
    response = create(:response, consultation: consultation)
    response.attachments << build(:attachment)
    assert_equal "Consultation outcome", consultation.display_type
  end

  test 'search_format_types tags the consultation as a consultation and publicationesque-consultation' do
    consultation = build(:consultation)
    assert consultation.search_format_types.include?('consultation')
    assert consultation.search_format_types.include?('publicationesque-consultation')
  end

  test "when the consultation is still open search_format_types tags the consultation as consultation-open" do
    consultation = build(:consultation, opening_on: Date.new(2011, 11, 1), closing_on: Date.new(2011, 12, 1))
    assert consultation.search_format_types.include?('consultation-open')
  end

  test "when the consultation is closed search_format_types tags the consultation as consultation-closed" do
    consultation = build(:consultation, opening_on: Date.new(2011, 7, 1), closing_on: Date.new(2011, 9, 1))
    assert consultation.search_format_types.include?('consultation-closed')
  end

  test "when the consultation has published the response search_format_types tags the consultation as consultation-outcome" do
    consultation = build(:consultation, opening_on: Date.new(2011, 5, 1), closing_on: Date.new(2011, 7, 1))
    response = create(:response, consultation: consultation)
    response.attachments << build(:attachment)
    assert consultation.search_format_types.include?('consultation-outcome')
  end

  test "can be associated with worldwide priorities" do
    assert Consultation.new.can_be_associated_with_worldwide_priorities?
  end

  test "can associate consultations with topical events" do
    consultation = create(:consultation)
    assert consultation.can_be_associated_with_topical_events?
    assert topical_event = consultation.topical_events.create(name: "Test", description: "Test")
    assert_equal [consultation], topical_event.consultations
  end

end
