require "test_helper"

class MigrateConsultationToCallForEvidenceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:whodunnit) { create(:user) }
  let(:document) { consultation.document }

  # Create a full-fat Consultation to exercise the various different fields
  # and associated records that should be accommodated for when migrating.
  let!(:consultation) do
    create(
      :published_consultation,
      # Attachments on the Consultation
      :with_alternative_format_provider,
      attachments: [
        build(:file_attachment),
        build(:html_attachment),
      ],
      images: build_list(:image, 1),

      # Applies to all UK nations except Scotland
      all_nation_applicability: false,
      nation_inapplicabilities: [
        build(:nation_inapplicability, excluded: true, alternative_url: "https://www.gov.scot"),
      ],

      # A consultation outcome with attachments
      outcome: build(:consultation_outcome, attachments: [
        build(:file_attachment),
        build(:html_attachment),
      ]),

      # How to participate in the consultation
      # including an attached response form file
      consultation_participation: build(
        :consultation_participation,
        link_url: "https://department.gov.uk/respond",
        email: "responses@department.gov.uk",
        postal_address: "10 Downing Street\nLondon\nSW1A 2AA",
        consultation_response_form: build(:consultation_response_form),
      ),
    )
  end

  let(:call_for_evidence) { document.latest_edition if document.latest_edition.is_a?(CallForEvidence) }

  def migrate
    DataHygiene::MigrateConsultationToCallForEvidence.new(document:, whodunnit:).call
    document.reload
  end

  # Stub HTTP requests for assets so that CarrierWave
  # can download files from Consultations and
  # upload them to Calls For Evidence
  def stub_asset_downloads
    # Make CarrierWave use WebMock
    # See: https://github.com/carrierwaveuploader/carrierwave/issues/2531#issuecomment-776623496
    CarrierWave::Downloader::Base.any_instance.stubs(:skip_ssrf_protection?).returns(true)

    # Stub requests for asset files
    # and respond with the requested fixture file
    urls_starting = "https://static.test.gov.uk/government/uploads/system/uploads/"
    stub_request(:get, %r{^#{Regexp.escape(urls_starting)}})
      .to_return do |request|
        fixture_name = request.uri.to_s.split("/").last
        { status: 200, body: file_fixture(fixture_name) }
      end
  end

  def assert_equal_attachments(expected, actual)
    ignore_attributes = %w[id attachable_id attachable_type safely_resluggable html_attachment_id ordering]

    attachment_attributes = lambda do |attachment|
      attributes = attachment.attributes.except(*ignore_attributes)

      if attachment.is_a? HtmlAttachment
        attributes["govspeak_content"] = attachment.govspeak_content.attributes.except(*ignore_attributes)
      end

      attributes
    end

    assert_equal expected.map(&attachment_attributes), actual.map(&attachment_attributes)
    assert actual.none?(&:safely_resluggable)
  end

  def assert_equal_images(expected, actual)
    ignore_attributes = %w[id edition_id]

    image_attributes = lambda do |image|
      image.attributes.except(*ignore_attributes)
    end

    assert_equal expected.map(&image_attributes), actual.map(&image_attributes)
  end

  before do
    stub_asset_downloads
  end

  it "refreshes the search index for the old and new edition" do
    Whitehall::SearchIndex.expects(:delete).once.with(consultation)
    Whitehall::SearchIndex.expects(:add).once.with(instance_of(CallForEvidence))

    migrate
  end

  it "converts a Consultation document into a Call for Evidence" do
    migrate

    # They have the same attributes
    ignore_attributes = %w[id type state auth_bypass_id minor_change change_note force_published lock_version published_minor_version]
    assert_equal consultation.attributes.except(*ignore_attributes),
                 call_for_evidence.attributes.except(*ignore_attributes)

    # and the same content
    assert_equal consultation.title, call_for_evidence.title
    assert_equal consultation.summary, call_for_evidence.summary
    assert_equal consultation.body, call_for_evidence.body

    # and the same attachments
    assert_equal_attachments consultation.attachments, call_for_evidence.attachments
    assert_equal_images consultation.images, call_for_evidence.images

    # and they apply to the same nations
    assert_equal consultation.national_applicability, call_for_evidence.national_applicability

    # The document is in the state we expect it to be
    assert_equal 2, document.editions.count
    assert_instance_of CallForEvidence, document.latest_edition
    assert_equal "CallForEvidence", document.document_type
    assert consultation.reload.superseded?
    assert call_for_evidence.published?
  end

  it "converts the Consultation Outcome to a Call for Evidence Outcome" do
    migrate

    # Both outcomes have the same attributes
    ignore_attributes = %w[id edition_id type]
    assert_equal consultation.outcome.attributes.except(*ignore_attributes),
                 call_for_evidence.outcome.attributes.except(*ignore_attributes)

    # and the same attachments
    assert_equal_attachments consultation.outcome.attachments,
                             call_for_evidence.outcome.attachments
  end

  it "converts the Consultation Participation to a Call for Evidence Participation" do
    # Assert that a file gets uploaded to Asset Manager
    AssetManagerCreateWhitehallAssetWorker.expects(:perform_async).at_least_once

    migrate

    consultation_participation = consultation.consultation_participation
    call_for_evidence_participation = call_for_evidence.call_for_evidence_participation

    # Both participation records have the same attributes
    ignore_attributes = %w[id edition_id type consultation_response_form_id call_for_evidence_response_form_id]
    assert_equal consultation_participation.attributes.except(*ignore_attributes),
                 call_for_evidence_participation.attributes.except(*ignore_attributes)

    # The response form has been migrated
    assert consultation_participation.has_response_form?
    assert call_for_evidence_participation.has_response_form?

    consultation_response_form = {
      title: consultation_participation.consultation_response_form.title,
      filename: consultation_participation.consultation_response_form.file.identifier,
    }

    call_for_evidence_response_form = {
      title: call_for_evidence_participation.call_for_evidence_response_form.title,
      filename: call_for_evidence_participation.call_for_evidence_response_form.file.identifier,
    }

    assert_equal consultation_response_form, call_for_evidence_response_form
  end

  it "attributes the migration to the whodunnit user" do
    migrate

    assert_equal whodunnit, call_for_evidence.creator
    assert_equal [whodunnit], call_for_evidence.versions.map(&:user).uniq
  end

  it "publishes the new call for evidence edition" do
    migrate

    assert consultation.reload.superseded?
    assert call_for_evidence.published?
  end

  it "creates a note when it is published" do
    migrate

    assert call_for_evidence.editorial_remarks.first.body, "Consultation document type migrated to call for evidence document type"
  end

  describe "merging Public Feedback with Outcome" do
    let(:public_feedback) do
      build(
        :consultation_public_feedback,
        attachments: [
          build(:csv_attachment),
          build(:html_attachment),
        ],
      )
    end

    context "when the Consultation has both Public Feedback and an Outcome" do
      before do
        consultation.update!(public_feedback:)
      end

      it "merges the Public Feedback and Outcome into the Call for Evidence Outcome" do
        migrate

        # Summaries have been merged
        assert_equal "#{consultation.outcome.summary}\n\n#{consultation.public_feedback.summary}",
                     call_for_evidence.outcome.summary

        # Attachments have been merged
        assert_equal_attachments consultation.outcome.attachments + consultation.public_feedback.attachments,
                                 call_for_evidence.outcome.attachments
      end
    end

    context "when the Consultation only has Public Feedback" do
      before do
        consultation.outcome.destroy!
        consultation.update!(public_feedback:)
      end

      it "moves the Public Feedback to the Call for Evidence Outcome" do
        migrate

        # Summaries have been merged
        assert_equal consultation.public_feedback.summary,
                     call_for_evidence.outcome.summary

        # Attachments have been merged
        assert_equal_attachments consultation.public_feedback.attachments,
                                 call_for_evidence.outcome.attachments
      end
    end
  end

  describe "invalid documents" do
    context "when latest edition is not a consultation" do
      let(:consultation) { create(:published_news_story) }

      it "rejects the document" do
        error = assert_raises(RuntimeError) { migrate }
        assert_equal "This is not a Consultation: NewsArticle", error.message
      end
    end

    context "when the document has a draft edition" do
      before do
        consultation.create_draft(whodunnit)
      end

      it "rejects the document" do
        error = assert_raises(RuntimeError) { migrate }
        assert_equal "The latest edition is not publicly visible: draft", error.message
      end
    end
  end
end
