require "test_helper"

class ConsultationTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_be_attachable
  should_not_allow_inline_attachments
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

  %i[imported deleted].each do |state|
    test "#{state} editions are valid without an opening at time" do
      edition = build(:consultation, state: state, opening_at: nil)
      assert edition.valid?
    end

    test "#{state} editions are valid without a closing at time" do
      edition = build(:consultation, state: state, closing_at: nil)
      assert edition.valid?
    end

    test "#{state} consultations with a blank opening at time have no first_public_at" do
      edition = build(:consultation, state: state, opening_at: nil)
      assert_nil edition.first_public_at
    end

    test "#{state} consultations with a blank opening at time are not open?, they are not_yet_open?" do
      edition = build(:consultation, state: state, opening_at: nil)
      refute edition.open?
      assert edition.not_yet_open?
    end

    test "#{state} consultations with a blank closing at time are closed?" do
      edition = build(:consultation, state: state, closing_at: nil)
      assert edition.closed?
    end
  end

  %i[draft scheduled published submitted rejected].each do |state|
    test "#{state} editions are not valid without an opening at time" do
      edition = build(:consultation, state: state, opening_at: nil)
      refute edition.valid?
    end

    test "#{state} editions are not valid without a closing at time" do
      edition = build(:consultation, state: state, closing_at: nil)
      refute edition.valid?
    end
  end

  test "external consultations must have a valid external URL" do
    edition = build(:consultation, external: true, external_url: nil)

    refute edition.valid?
    assert_equal "can't be blank", edition.errors[:external_url].first

    edition.external_url = 'bad.url'
    refute edition.valid?
    assert_match %r[not valid], edition.errors[:external_url].first
  end

  test "should be invalid if the opening time is after the closing time" do
    consultation = build(:consultation, opening_at: 1.day.ago, closing_at: 2.days.ago)
    refute consultation.valid?
  end

  test "should build a draft copy of the existing consultation with inapplicable nations" do
    published_consultation = create(:published_consultation, nation_inapplicabilities: [
      create(:nation_inapplicability, nation_id: Nation.wales.id, alternative_url: "http://wales.gov.uk"),
      create(:nation_inapplicability, nation_id: Nation.scotland.id, alternative_url: "http://scot.gov.uk")
    ])

    draft_consultation = published_consultation.create_draft(create(:writer))

    assert_equal published_consultation.inapplicable_nations, draft_consultation.inapplicable_nations
    assert_equal "http://wales.gov.uk", draft_consultation.nation_inapplicabilities.find_by(nation_id: Nation.wales.id).alternative_url
    assert_equal "http://scot.gov.uk", draft_consultation.nation_inapplicabilities.find_by(nation_id: Nation.scotland.id).alternative_url
  end

  test ".closed includes consultations which have run and closed already" do
    closed_consultation = create(:consultation, opening_at: 2.days.ago, closing_at: 5.minutes.ago)

    assert_equal 1, Consultation.closed.count
    assert_equal closed_consultation, Consultation.closed.first
  end

  test ".closed excludes consultations closing in the future" do
    _open_consultation = create(:consultation, opening_at: 2.days.ago, closing_at: 1.minute.from_now)

    assert_equal 0, Consultation.closed.count
  end

  test ".closed_at_or_after only includes consultations closed at or after the specified time" do
    closed_three_days_ago = create(:consultation, opening_at: 1.month.ago, closing_at: 3.days.ago)
    closed_two_days_ago = create(:consultation, opening_at: 1.month.ago, closing_at: 2.days.ago)
    _open = create(:consultation, opening_at: 1.month.ago, closing_at: 1.day.from_now)

    assert_same_elements [], Consultation.closed_at_or_after(1.days.ago)
    assert_same_elements [closed_two_days_ago], Consultation.closed_at_or_after(2.days.ago)
    assert_same_elements [closed_two_days_ago, closed_three_days_ago], Consultation.closed_at_or_after(3.days.ago)
  end

  test ".closed_on includes consultations closed on the specified date" do
    closed_yesterday = FactoryBot.create(:closed_consultation, closing_at: 1.day.ago)
    closed_today = FactoryBot.create(:closed_consultation, closing_at: 5.minutes.ago)
    FactoryBot.create(:open_consultation)

    assert_same_elements [closed_yesterday], Consultation.closed_on(Date.yesterday)
    assert_same_elements [closed_today], Consultation.closed_on(Date.today)
    assert_same_elements [], Consultation.closed_on(Date.tomorrow)
  end

  test ".responded includes closed consultations with an outcome" do
    closed_with_outcome = FactoryBot.create(:consultation_with_outcome)
    FactoryBot.create(:closed_consultation)
    FactoryBot.create(:open_consultation)

    assert_same_elements [closed_with_outcome], Consultation.responded
  end

  test ".awaiting_response includes closed consultations with no outcome" do
    FactoryBot.create(:consultation_with_outcome)
    closed_without_outcome = FactoryBot.create(:closed_consultation)
    FactoryBot.create(:open_consultation)

    assert_same_elements [closed_without_outcome], Consultation.awaiting_response
  end

  test ".open includes consultations closing in the future and opening in the past" do
    open_consultation = create(:consultation, opening_at: 2.days.ago, closing_at: 10.minutes.from_now)

    assert_equal 1, Consultation.open.count
    assert_equal open_consultation, Consultation.open.first
  end

  test ".open excludes consultations opening in the future" do
    _upcoming_consultation = create(:consultation, opening_at: 10.minutes.from_now, closing_at: 2.days.from_now)

    assert_equal 0, Consultation.open.count
  end

  test ".open excludes consultations closing in the past" do
    _closed_consultation = create(:consultation, opening_at: 2.days.ago, closing_at: 10.minutes.ago)

    assert_equal 0, Consultation.open.count
  end

  test ".opened_at_or_after only includes consultations open at or after the specified time" do
    create(:consultation, opening_at: 1.month.ago)
    open_three_days_ago = create(:consultation, opening_at: 3.days.ago)
    open_two_days_ago = create(:consultation, opening_at: 2.days.ago)

    assert_same_elements [], Consultation.opened_at_or_after(1.days.ago)
    assert_same_elements [open_two_days_ago], Consultation.opened_at_or_after(2.days.ago)
    assert_same_elements [open_two_days_ago, open_three_days_ago], Consultation.opened_at_or_after(3.days.ago)
  end

  test ".upcoming includes consultations opening in the future" do
    upcoming_consultation = create(:consultation, opening_at: 10.minutes.from_now, closing_at: 2.days.from_now)

    assert_equal 1, Consultation.upcoming.count
    assert_equal upcoming_consultation, Consultation.upcoming.first
  end

  test ".upcoming excludes consultations opening in the past" do
    _open_consultation = create(:consultation, opening_at: 10.minutes.ago, closing_at: 1.day.from_now)
    _closed_consultation = create(:consultation, opening_at: 2.days.ago, closing_at: 10.minutes.ago)

    assert_equal 0, Consultation.upcoming.count
  end

  test "should not create a participation if all participation fields are blank" do
    attributes = { link_url: nil, consultation_response_form_attributes: { title: nil, file: nil } }
    consultation = create(:consultation, consultation_participation_attributes: attributes)
    assert consultation.consultation_participation.blank?
  end

  test "should preserve original participation when creating new edition" do
    consultation_participation = create(:consultation_participation, link_url: "http://example.com")
    consultation = create(:published_consultation, consultation_participation: consultation_participation)

    new_draft = consultation.create_draft(create(:writer))

    assert_equal new_draft.consultation_participation.link_url, consultation_participation.link_url, "link attribute should be copied"
  end

  test "should destroy associated consultation participation when destroyed" do
    consultation_participation = create(:consultation_participation, link_url: "http://example.com")
    consultation = create(:consultation, consultation_participation: consultation_participation)
    consultation.destroy
    refute ConsultationParticipation.exists?(consultation_participation.id)
  end

  test "should destroy the consultation outcome when the consultation is destroyed" do
    consultation = create(:consultation)
    outcome = create(:consultation_outcome, consultation: consultation)

    consultation.destroy

    refute ConsultationOutcome.exists?(outcome.id)
  end

  test "should copy the outcome summary and link to the original attachments when creating a new draft" do
    consultation = create(:published_consultation)
    outcome = create(:consultation_outcome, consultation: consultation, attachments: [
      attachment = build(:file_attachment, title: 'attachment-title')
    ])

    new_draft = consultation.create_draft(build(:user))
    new_draft.reload

    assert_equal outcome.summary, new_draft.outcome.summary
    assert_not_equal outcome, new_draft.outcome
    assert_equal 1, new_draft.outcome.attachments.length
    assert_equal 'attachment-title', new_draft.outcome.attachments.first.title
    assert_not_equal attachment, new_draft.outcome.attachments.first
    assert_equal attachment.attachment_data, new_draft.outcome.attachments.first.attachment_data
  end

  test "should copy the outcome without falling over if the outcome has attachments but no summary" do
    consultation = create(:published_consultation)
    create(:consultation_outcome, consultation: consultation, summary: '', attachments: [
      build(:file_attachment, title: 'attachment-title', attachment_data_attributes: { file: fixture_file_upload('greenpaper.pdf') })
    ])

    assert_nothing_raised {
      new_draft = consultation.create_draft(build(:user))
      assert_equal 1, new_draft.outcome.attachments.length
    }
  end

  test "copies public feedback and its attachments when creating a new draft" do
    consultation = create(:published_consultation)
    feedback = create(:consultation_public_feedback, consultation: consultation, attachments: [
      attachment = build(:file_attachment, title: 'attachment-title', attachment_data_attributes: { file: fixture_file_upload('greenpaper.pdf') })
    ])

    new_draft = consultation.create_draft(build(:user))
    new_draft.reload

    assert new_feedback = new_draft.public_feedback
    assert_equal feedback.summary, new_feedback.summary
    assert_not_equal feedback, new_feedback

    assert_equal 1, new_feedback.attachments.length
    assert_equal 'attachment-title', new_feedback.attachments.first.title
    assert_not_equal attachment, new_feedback.attachments.first
    assert_equal attachment.attachment_data, new_feedback.attachments.first.attachment_data
  end

  test "should copy public feedback without falling over if the feedback has attachments but no summary" do
    consultation = create(:published_consultation)
    create(:consultation_public_feedback, consultation: consultation, summary: '', attachments: [
      build(:file_attachment, title: 'attachment-title', attachment_data_attributes: { file: fixture_file_upload('greenpaper.pdf') })
    ])

    assert_nothing_raised {
      new_draft = consultation.create_draft(build(:user))
      assert_equal 1, new_draft.public_feedback.attachments.length
    }
  end

  test "should report that the outcome has not been published if the consultation is still open" do
    consultation = create(:consultation, opening_at: 1.day.ago, closing_at: 1.month.from_now)

    refute consultation.outcome_published?
  end

  test "should report that the outcome has not been published if the consultation is closed and there is no outcome" do
    consultation = create(:consultation, opening_at: 2.days.ago, closing_at: 1.day.ago)

    refute consultation.outcome_published?
  end

  test "should report that the outcome has been published if the consultation is closed and there is an outcome" do
    consultation = create(:consultation, opening_at: 2.days.ago, closing_at: 1.day.ago)
    _outcome = create(:consultation_outcome, consultation: consultation)

    assert consultation.outcome_published?
  end

  test "should return the published_on date of the outcome" do
    today = Date.today
    consultation = create(:consultation)
    outcome = create(:consultation_outcome, consultation: consultation)
    outcome.stubs(:published_on).returns(today)

    assert_equal today, consultation.outcome_published_on
  end

  test "make_public_at should set first_published_at" do
    consultation = build(:consultation, first_published_at: nil)
    consultation.make_public_at(2.days.ago)
    assert consultation.first_published_at
  end

  test "display_type when not yet open" do
    consultation = build(:consultation, opening_at: 10.minutes.from_now, closing_at: 10.days.from_now)
    assert_equal "Consultation", consultation.display_type
  end

  test "display_type when open" do
    consultation = build(:consultation, opening_at: 10.minutes.ago, closing_at: 10.minutes.from_now)
    assert_equal "Open consultation", consultation.display_type
  end

  test "display_type when closed" do
    consultation = build(:consultation, opening_at: 10.days.ago, closing_at: 10.minutes.ago)
    assert_equal "Closed consultation", consultation.display_type
  end

  test "display_type when outcome published" do
    consultation = build(:consultation, opening_at: 10.days.ago, closing_at: 10.minutes.ago)
    outcome = create(:consultation_outcome, consultation: consultation)
    outcome.attachments << build(:file_attachment)
    assert_equal "Consultation outcome", consultation.display_type
  end

  test 'search_format_types tags the consultation as a consultation and publicationesque-consultation' do
    consultation = build(:consultation)
    assert consultation.search_format_types.include?('consultation')
    assert consultation.search_format_types.include?('publicationesque-consultation')
  end

  test "when the consultation is still open search_format_types tags the consultation as consultation-open" do
    consultation = build(:consultation, opening_at: 10.minutes.ago, closing_at: 10.minutes.from_now)
    assert consultation.search_format_types.include?('consultation-open')
  end

  test "when the consultation is closed search_format_types tags the consultation as consultation-closed" do
    consultation = build(:consultation, opening_at: 10.days.ago, closing_at: 10.minutes.ago)
    assert consultation.search_format_types.include?('consultation-closed')
  end

  test "when the consultation has published the outcome search_format_types tags the consultation as consultation-outcome" do
    consultation = build(:consultation, opening_at: 10.days.ago, closing_at: 10.minutes.ago)
    outcome = create(:consultation_outcome, consultation: consultation)
    outcome.attachments << build(:file_attachment)
    assert consultation.search_format_types.include?('consultation-outcome')
  end

  test "can associate consultations with topical events" do
    consultation = create(:consultation)
    assert consultation.can_be_associated_with_topical_events?
    assert topical_event = consultation.topical_events.create(name: "Test", description: "Test")
    assert_equal [consultation], topical_event.consultations
  end

  test "#search_index :has_official_document should be true if either the consultation or it's outcome has official document attachments" do
    Consultation.any_instance.stubs(:search_link)

    refute create(:consultation).search_index[:has_official_document]

    command_paper_consultation = create(:consultation)
    command_paper_consultation.stubs(:has_official_document?).returns(true)
    assert command_paper_consultation.search_index[:has_official_document]

    consultation_with_command_paper_outcome = create(:consultation, outcome: create(:consultation_outcome))
    consultation_with_command_paper_outcome.outcome.stubs(:has_official_document?).returns(true)
    assert consultation_with_command_paper_outcome.search_index[:has_official_document]
  end

  test "#search_index :has_command_paper should be true if either the consultation or it's outcome has command paper attachments" do
    Consultation.any_instance.stubs(:search_link)

    refute create(:consultation).search_index[:has_command_paper]

    command_paper_consultation = create(:consultation)
    command_paper_consultation.stubs(:has_command_paper?).returns(true)
    assert command_paper_consultation.search_index[:has_command_paper]

    consultation_with_command_paper_outcome = create(:consultation, outcome: create(:consultation_outcome))
    consultation_with_command_paper_outcome.outcome.stubs(:has_command_paper?).returns(true)
    assert consultation_with_command_paper_outcome.search_index[:has_command_paper]
  end

  test "#search_index :has_act_paper should be true if either the consultation or it's outcome has act paper attachments" do
    Consultation.any_instance.stubs(:search_link)

    consultation = create(:consultation)
    refute consultation.search_index[:has_act_paper]

    command_paper_consultation = create(:consultation)
    command_paper_consultation.stubs(:has_act_paper?).returns(true)
    assert command_paper_consultation.search_index[:has_act_paper]

    consultation_with_command_paper_outcome = create(:consultation, outcome: create(:consultation_outcome))
    consultation_with_command_paper_outcome.outcome.stubs(:has_act_paper?).returns(true)
    assert consultation_with_command_paper_outcome.search_index[:has_act_paper]
  end

  test "#government returns the government active on the first_public_at date" do
    create(:current_government)
    previous_government = create(:previous_government)
    consultation = create(:consultation, first_published_at: 4.years.ago)

    assert_equal previous_government, consultation.government
  end

  test "#save triggers consultation opening in the future to be republished twice" do
    opening_at = 2.days.from_now
    closing_at = 3.days.from_now

    consultation = create(:consultation, opening_at: opening_at, closing_at: closing_at)

    PublishingApiDocumentRepublishingWorker
      .expects(:perform_at)
      .with(opening_at, consultation.document.id)
      .once

    PublishingApiDocumentRepublishingWorker
      .expects(:perform_at)
      .with(closing_at, consultation.document.id)
      .once

    consultation.save
  end

  test "#save triggers consultation closing in the future to be republished once" do
    opening_at = 2.days.ago
    closing_at = 3.days.from_now

    consultation = create(:consultation, opening_at: opening_at, closing_at: closing_at)

    PublishingApiDocumentRepublishingWorker
      .expects(:perform_at)
      .with(opening_at, consultation.document.id)
      .never

    PublishingApiDocumentRepublishingWorker
      .expects(:perform_at)
      .with(closing_at, consultation.document.id)
      .once

    consultation.save
  end

  test '#attachables returns array including itself' do
    consultation = build(:consultation)
    assert_equal [consultation], consultation.attachables
  end

  test '#attachables returns array including itself & outcome' do
    outcome = build(:consultation_outcome)
    consultation = build(:consultation, outcome: outcome)
    assert_equal [consultation, outcome], consultation.attachables
  end

  test '#attachables returns array including itself & public feedback' do
    public_feedback = build(:consultation_public_feedback)
    consultation = build(:consultation, public_feedback: public_feedback)
    assert_equal [consultation, public_feedback], consultation.attachables
  end

  test '#attachables returns array including itself, outcome & public feedback' do
    outcome = build(:consultation_outcome)
    public_feedback = build(:consultation_public_feedback)
    consultation = build(:consultation, outcome: outcome, public_feedback: public_feedback)
    assert_equal [consultation, outcome, public_feedback], consultation.attachables
  end
end
