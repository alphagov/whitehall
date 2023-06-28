require "test_helper"

class CallForEvidenceTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_be_attachable
  should_not_allow_inline_attachments
  should_protect_against_xss_and_content_attacks_on :call_for_evidence, :title, :body, :summary, :change_note

  %i[deleted].each do |state|
    test "#{state} editions are valid without an opening at time" do
      edition = build(:call_for_evidence, state:, opening_at: nil)
      assert edition.valid?
    end

    test "#{state} editions are valid without a closing at time" do
      edition = build(:call_for_evidence, state:, closing_at: nil)
      assert edition.valid?
    end

    test "#{state} editions are valid with a non-English primary locale" do
      edition = build(:call_for_evidence, state:)
      edition.primary_locale = "cy"
      assert edition.valid?
    end

    test "#{state} calls for evidence with a blank opening at time have no first_public_at" do
      edition = build(:call_for_evidence, state:, opening_at: nil)
      assert_nil edition.first_public_at
    end

    test "#{state} calls for evidence with a blank opening at time are not open?, they are not_yet_open?" do
      edition = build(:call_for_evidence, state:, opening_at: nil)
      assert_not edition.open?
      assert edition.not_yet_open?
    end

    test "#{state} calls for evidence with a blank closing at time are closed?" do
      edition = build(:call_for_evidence, state:, closing_at: nil)
      assert edition.closed?
    end
  end

  %i[draft scheduled published submitted rejected].each do |state|
    test "#{state} editions are not valid without an opening at time" do
      edition = build(:call_for_evidence, state:, opening_at: nil)
      assert_not edition.valid?
    end

    test "#{state} editions are not valid without a closing at time" do
      edition = build(:call_for_evidence, state:, closing_at: nil)
      assert_not edition.valid?
    end
  end

  test "external calls for evidence must have a valid external URL" do
    edition = build(:call_for_evidence, external: true, external_url: nil)

    assert_not edition.valid?
    assert_equal "can't be blank", edition.errors[:external_url].first

    edition.external_url = "bad.url"
    assert_not edition.valid?
    assert_match %r{not valid}, edition.errors[:external_url].first
  end

  test "should be invalid if the opening time is after the closing time" do
    call_for_evidence = build(:call_for_evidence, opening_at: 1.day.ago, closing_at: 2.days.ago)
    assert_not call_for_evidence.valid?
  end

  test "should build a draft copy of the existing call for evidence with inapplicable nations" do
    published_call_for_evidence = create(
      :published_call_for_evidence_with_excluded_nations,
      nation_inapplicabilities: [
        create(:nation_inapplicability, nation_id: Nation.wales.id, alternative_url: "http://wales.gov.uk"),
        create(:nation_inapplicability, nation_id: Nation.scotland.id, alternative_url: "http://scot.gov.uk"),
      ],
    )

    draft_call_for_evidence = published_call_for_evidence.create_draft(create(:writer))

    assert_equal published_call_for_evidence.inapplicable_nations, draft_call_for_evidence.inapplicable_nations
    assert_equal "http://wales.gov.uk", draft_call_for_evidence.nation_inapplicabilities.find_by(nation_id: Nation.wales.id).alternative_url
    assert_equal "http://scot.gov.uk", draft_call_for_evidence.nation_inapplicabilities.find_by(nation_id: Nation.scotland.id).alternative_url
  end

  test ".closed includes calls for evidence which have run and closed already" do
    closed_call_for_evidence = create(:call_for_evidence, opening_at: 2.days.ago, closing_at: 5.minutes.ago)

    assert_equal 1, CallForEvidence.closed.count
    assert_equal closed_call_for_evidence, CallForEvidence.closed.first
  end

  test ".closed excludes calls for evidence closing in the future" do
    _open_call_for_evidence = create(:call_for_evidence, opening_at: 2.days.ago, closing_at: 1.minute.from_now)

    assert_equal 0, CallForEvidence.closed.count
  end

  test ".closed_at_or_after only includes calls for evidence closed at or after the specified time" do
    closed_three_days_ago = create(:call_for_evidence, opening_at: 1.month.ago, closing_at: 3.days.ago)
    closed_two_days_ago = create(:call_for_evidence, opening_at: 1.month.ago, closing_at: 2.days.ago)
    _open = create(:call_for_evidence, opening_at: 1.month.ago, closing_at: 1.day.from_now)

    assert_same_elements [], CallForEvidence.closed_at_or_after(1.day.ago)
    assert_same_elements [closed_two_days_ago], CallForEvidence.closed_at_or_after(2.days.ago)
    assert_same_elements [closed_two_days_ago, closed_three_days_ago], CallForEvidence.closed_at_or_after(3.days.ago)
  end

  test ".closed_at_or_within_24_hours_of includes Calls for evidence closed at or in the 24 hours running up to the specified time" do
    base_time = 1.day
    closed_now = FactoryBot.create(:closed_call_for_evidence, closing_at: base_time.ago)
    closed_an_hour_ago = FactoryBot.create(:closed_call_for_evidence, closing_at: (base_time + 1.hour).ago)
    closed_less_than_24_hours_ago = FactoryBot.create(:closed_call_for_evidence, opening_at: 10.days.ago, closing_at: (base_time + 23.hours + 59.minutes + 59.seconds).ago)
    FactoryBot.create(:closed_call_for_evidence, opening_at: 10.days.ago, closing_at: (base_time + 24.hours).ago)
    FactoryBot.create(:closed_call_for_evidence, opening_at: 10.days.ago, closing_at: (base_time + 25.hours).ago)
    FactoryBot.create(:open_call_for_evidence)

    assert_same_elements [closed_now, closed_an_hour_ago, closed_less_than_24_hours_ago], CallForEvidence.closed_at_or_within_24_hours_of(base_time.ago)
  end

  test ".responded includes closed calls for evidence with an outcome" do
    closed_with_outcome = FactoryBot.create(:call_for_evidence_with_outcome)
    FactoryBot.create(:closed_call_for_evidence)
    FactoryBot.create(:open_call_for_evidence)

    assert_same_elements [closed_with_outcome], CallForEvidence.responded
  end

  test ".awaiting_response includes published closed calls for evidence with no outcome" do
    FactoryBot.create(:call_for_evidence_with_outcome)
    closed_without_outcome = FactoryBot.create(:closed_call_for_evidence)
    FactoryBot.create(:closed_call_for_evidence, :superseded)
    FactoryBot.create(:open_call_for_evidence)

    assert_same_elements [closed_without_outcome], CallForEvidence.awaiting_response
  end

  test ".open includes  closing in the future and opening in the past" do
    open_call_for_evidence = create(:call_for_evidence, opening_at: 2.days.ago, closing_at: 10.minutes.from_now)

    assert_equal 1, CallForEvidence.open.count
    assert_equal open_call_for_evidence, CallForEvidence.open.first
  end

  test ".open excludes calls for evidence opening in the future" do
    _upcoming_call_for_evidence = create(:call_for_evidence, opening_at: 10.minutes.from_now, closing_at: 2.days.from_now)

    assert_equal 0, CallForEvidence.open.count
  end

  test ".open excludes calls for evidence closing in the past" do
    _closed_call_for_evidence = create(:call_for_evidence, opening_at: 2.days.ago, closing_at: 10.minutes.ago)

    assert_equal 0, CallForEvidence.open.count
  end

  test ".opened_at_or_after only includes calls for evidence open at or after the specified time" do
    create(:call_for_evidence, opening_at: 1.month.ago)
    open_three_days_ago = create(:call_for_evidence, opening_at: 3.days.ago)
    open_two_days_ago = create(:call_for_evidence, opening_at: 2.days.ago)

    assert_same_elements [], CallForEvidence.opened_at_or_after(1.day.ago)
    assert_same_elements [open_two_days_ago], CallForEvidence.opened_at_or_after(2.days.ago)
    assert_same_elements [open_two_days_ago, open_three_days_ago], CallForEvidence.opened_at_or_after(3.days.ago)
  end

  test ".upcoming includes calls for evidence opening in the future" do
    upcoming_call_for_evidence = create(:call_for_evidence, opening_at: 10.minutes.from_now, closing_at: 2.days.from_now)

    assert_equal 1, CallForEvidence.upcoming.count
    assert_equal upcoming_call_for_evidence, CallForEvidence.upcoming.first
  end

  test ".upcoming excludes calls for evidence opening in the past" do
    _open_call_for_evidence = create(:call_for_evidence, opening_at: 10.minutes.ago, closing_at: 1.day.from_now)
    _closed_call_for_evidence = create(:call_for_evidence, opening_at: 2.days.ago, closing_at: 10.minutes.ago)

    assert_equal 0, CallForEvidence.upcoming.count
  end

  test "should not create a participation if all participation fields are blank" do
    attributes = { link_url: nil, call_for_evidence_response_form_attributes: { title: nil, file: nil } }
    call_for_evidence = create(:call_for_evidence, call_for_evidence_participation_attributes: attributes)
    assert call_for_evidence.call_for_evidence_participation.blank?
  end

  test "should preserve original participation when creating new edition" do
    call_for_evidence_participation = create(:call_for_evidence_participation, link_url: "http://example.com")
    call_for_evidence = create(:published_call_for_evidence, call_for_evidence_participation:)

    new_draft = call_for_evidence.create_draft(create(:writer))

    assert_equal new_draft.call_for_evidence_participation.link_url, call_for_evidence_participation.link_url, "link attribute should be copied"
  end

  test "should destroy associated call_for_evidence participation when destroyed" do
    call_for_evidence_participation = create(:call_for_evidence_participation, link_url: "http://example.com")
    call_for_evidence = create(:call_for_evidence, call_for_evidence_participation:)
    call_for_evidence.destroy!
    assert_not CallForEvidenceParticipation.exists?(call_for_evidence_participation.id)
  end

  test "should destroy the call for evidence outcome when the call for evidence is destroyed" do
    call_for_evidence = create(:call_for_evidence)
    outcome = create(:call_for_evidence_outcome, call_for_evidence:)

    call_for_evidence.destroy!

    assert_not CallForEvidenceOutcome.exists?(outcome.id)
  end

  test "should copy the outcome summary and link to the original attachments when creating a new draft" do
    call_for_evidence = create(:published_call_for_evidence)
    outcome = create(
      :call_for_evidence_outcome,
      call_for_evidence:,
      attachments: [
        attachment = build(:file_attachment, title: "attachment-title"),
      ],
    )

    new_draft = call_for_evidence.create_draft(build(:user))
    new_draft.reload

    assert_equal outcome.summary, new_draft.outcome.summary
    assert_not_equal outcome, new_draft.outcome
    assert_equal 1, new_draft.outcome.attachments.length
    assert_equal "attachment-title", new_draft.outcome.attachments.first.title
    assert_not_equal attachment, new_draft.outcome.attachments.first
    assert_equal attachment.attachment_data, new_draft.outcome.attachments.first.attachment_data
  end

  test "should copy the outcome without falling over if the outcome has attachments but no summary" do
    call_for_evidence = create(:published_call_for_evidence)
    create(
      :call_for_evidence_outcome,
      call_for_evidence:,
      summary: "",
      attachments: [
        build(:file_attachment, title: "attachment-title", attachment_data_attributes: { file: upload_fixture("greenpaper.pdf") }),
      ],
    )

    assert_nothing_raised do
      new_draft = call_for_evidence.create_draft(build(:user))
      assert_equal 1, new_draft.outcome.attachments.length
    end
  end

  test "should report that the outcome has not been published if the call for evidence is still open" do
    call_for_evidence = create(:call_for_evidence, opening_at: 1.day.ago, closing_at: 1.month.from_now)

    assert_not call_for_evidence.outcome_published?
  end

  test "should report that the outcome has not been published if the call for evidence is closed and there is no outcome" do
    call_for_evidence = create(:call_for_evidence, opening_at: 2.days.ago, closing_at: 1.day.ago)

    assert_not call_for_evidence.outcome_published?
  end

  test "should report that the outcome has been published if the call for evidence is closed and there is an outcome" do
    call_for_evidence = create(:call_for_evidence, opening_at: 2.days.ago, closing_at: 1.day.ago)
    _outcome = create(:call_for_evidence_outcome, call_for_evidence:)

    assert call_for_evidence.outcome_published?
  end

  test "should return the published_on date of the outcome" do
    today = Time.zone.today
    call_for_evidence = create(:call_for_evidence)
    outcome = create(:call_for_evidence_outcome, call_for_evidence:)
    outcome.stubs(:published_on).returns(today)

    assert_equal today, call_for_evidence.outcome_published_on
  end

  test "make_public_at should set first_published_at" do
    call_for_evidence = build(:call_for_evidence, first_published_at: nil)
    call_for_evidence.make_public_at(2.days.ago)
    assert call_for_evidence.first_published_at
  end

  test "display_type when not yet open" do
    call_for_evidence = build(:call_for_evidence, opening_at: 10.minutes.from_now, closing_at: 10.days.from_now)
    assert_equal "Call for evidence", call_for_evidence.display_type
  end

  test "display_type when open" do
    call_for_evidence = build(:call_for_evidence, opening_at: 10.minutes.ago, closing_at: 10.minutes.from_now)
    assert_equal "Open call for evidence", call_for_evidence.display_type
  end

  test "display_type when closed" do
    call_for_evidence = build(:call_for_evidence, opening_at: 10.days.ago, closing_at: 10.minutes.ago)
    assert_equal "Closed call for evidence", call_for_evidence.display_type
  end

  test "display_type when outcome published" do
    call_for_evidence = build(:call_for_evidence, opening_at: 10.days.ago, closing_at: 10.minutes.ago)
    outcome = create(:call_for_evidence_outcome, call_for_evidence:)
    outcome.attachments << build(:file_attachment)
    assert_equal "Call for evidence outcome", call_for_evidence.display_type
  end

  test "search_format_types tags the call for evidence as a call for evidence and publicationesque-call-for-evidence" do
    call_for_evidence = build(:call_for_evidence)
    assert call_for_evidence.search_format_types.include?("call-for-evidence")
    assert call_for_evidence.search_format_types.include?("publicationesque-call-for-evidence")
  end

  test "when the call for evidence is still open search_format_types tags the call for evidence as call-for-evidence-open" do
    call_for_evidence = build(:call_for_evidence, opening_at: 10.minutes.ago, closing_at: 10.minutes.from_now)
    assert call_for_evidence.search_format_types.include?("call-for-evidence-open")
  end

  test "when the call for evidence is closed search_format_types tags the call for evidence as call-for-evidence-closed" do
    call_for_evidence = build(:call_for_evidence, opening_at: 10.days.ago, closing_at: 10.minutes.ago)
    assert call_for_evidence.search_format_types.include?("call-for-evidence-closed")
  end

  test "when the call for evidence has published the outcome search_format_types tags the call for evidence as call-for-evidence-outcome" do
    call_for_evidence = build(:call_for_evidence, opening_at: 10.days.ago, closing_at: 10.minutes.ago)
    outcome = create(:call_for_evidence_outcome, call_for_evidence:)
    outcome.attachments << build(:file_attachment)
    assert call_for_evidence.search_format_types.include?("call-for-evidence-outcome")
  end

  test "can associate calls for evidence with topical events" do
    call_for_evidence = create(:call_for_evidence)
    assert call_for_evidence.can_be_associated_with_topical_events?
    assert topical_event = call_for_evidence.topical_events.create!(name: "Test", description: "Test", summary: "Test")
    assert_equal [call_for_evidence], topical_event.calls_for_evidence
  end

  test "#search_index :has_official_document should be true if the call for evidence has official document attachments" do
    CallForEvidence.any_instance.stubs(:search_link)

    assert_not create(:call_for_evidence).search_index[:has_official_document]

    command_paper_call_for_evidence = create(:call_for_evidence)
    command_paper_call_for_evidence.stubs(:has_official_document?).returns(true)
    assert command_paper_call_for_evidence.search_index[:has_official_document]

    call_for_evidence_with_command_paper_outcome = create(:call_for_evidence, outcome: create(:call_for_evidence_outcome))
    call_for_evidence_with_command_paper_outcome.outcome.stubs(:has_official_document?).returns(true)
    assert call_for_evidence_with_command_paper_outcome.search_index[:has_official_document]
  end

  test "#search_index :has_command_paper should be true if the call for evidence has command paper attachments" do
    CallForEvidence.any_instance.stubs(:search_link)

    assert_not create(:call_for_evidence).search_index[:has_command_paper]

    command_paper_call_for_evidence = create(:call_for_evidence)
    command_paper_call_for_evidence.stubs(:has_command_paper?).returns(true)
    assert command_paper_call_for_evidence.search_index[:has_command_paper]

    call_for_evidence_with_command_paper_outcome = create(:call_for_evidence, outcome: create(:call_for_evidence_outcome))
    call_for_evidence_with_command_paper_outcome.outcome.stubs(:has_command_paper?).returns(true)
    assert call_for_evidence_with_command_paper_outcome.search_index[:has_command_paper]
  end

  test "#search_index :has_act_paper should be true if the call for evidence has act paper attachments" do
    CallForEvidence.any_instance.stubs(:search_link)

    call_for_evidence = create(:call_for_evidence)
    assert_not call_for_evidence.search_index[:has_act_paper]

    command_paper_call_for_evidence = create(:call_for_evidence)
    command_paper_call_for_evidence.stubs(:has_act_paper?).returns(true)
    assert command_paper_call_for_evidence.search_index[:has_act_paper]

    call_for_evidence_with_command_paper_outcome = create(:call_for_evidence, outcome: create(:call_for_evidence_outcome))
    call_for_evidence_with_command_paper_outcome.outcome.stubs(:has_act_paper?).returns(true)
    assert call_for_evidence_with_command_paper_outcome.search_index[:has_act_paper]
  end

  test "#government returns the government active on the first_public_at date" do
    create(:current_government)
    previous_government = create(:previous_government)
    call_for_evidence = create(:call_for_evidence, first_published_at: 4.years.ago)

    assert_equal previous_government, call_for_evidence.government
  end

  test "#save triggers call for evidence opening in the future to be republished twice" do
    opening_at = 2.days.from_now
    closing_at = 3.days.from_now

    call_for_evidence = create(:call_for_evidence, opening_at:, closing_at:)

    PublishingApiDocumentRepublishingWorker
      .expects(:perform_at)
      .with(opening_at, call_for_evidence.document.id)
      .once

    PublishingApiDocumentRepublishingWorker
      .expects(:perform_at)
      .with(closing_at, call_for_evidence.document.id)
      .once

    call_for_evidence.save!
  end

  test "#save triggers call for evidence closing in the future to be republished once" do
    opening_at = 2.days.ago
    closing_at = 3.days.from_now

    call_for_evidence = create(:call_for_evidence, opening_at:, closing_at:)

    PublishingApiDocumentRepublishingWorker
      .expects(:perform_at)
      .with(opening_at, call_for_evidence.document.id)
      .never

    PublishingApiDocumentRepublishingWorker
      .expects(:perform_at)
      .with(closing_at, call_for_evidence.document.id)
      .once

    call_for_evidence.save!
  end

  test "#attachables returns array including itself" do
    outcome = build(:call_for_evidence_outcome)
    call_for_evidence = build(:call_for_evidence, outcome:)
    assert_equal [call_for_evidence, outcome], call_for_evidence.attachables
  end

  test "calls for evidence cannot be previously published" do
    assert_not build(:call_for_evidence).previously_published
  end

  test "#all_nation_applicability_selected? false if first draft and unsaved" do
    unsaved_publication = build(:call_for_evidence)
    assert_not unsaved_publication.all_nation_applicability_selected?
  end

  test "#all_nation_applicability_selected? responds to all_nation_applicability once created" do
    published_publication = create(:call_for_evidence)
    assert published_publication.all_nation_applicability_selected?
    published_with_excluded = create(:published_call_for_evidence_with_excluded_nations, nation_inapplicabilities: [create(:nation_inapplicability, nation: Nation.scotland, alternative_url: "http://scotland.com")])
    assert_not published_with_excluded.all_nation_applicability_selected?
  end

  test "#string_for_slug returns title for slug string regardless of locale" do
    en_call_for_evidence = create(:call_for_evidence, title: "title-en")
    cy_call_for_evidence = create(:call_for_evidence, primary_locale: "cy", title: "title-cy")

    [en_call_for_evidence, cy_call_for_evidence].each do |call_for_evidence|
      assert_equal call_for_evidence.document.slug, call_for_evidence.title
    end
  end
end
