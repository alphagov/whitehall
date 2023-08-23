require "test_helper"

class MigrateConsultationToCallForEvidenceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:whodunnit) { create(:user) }
  let(:document) { consultation.document }

  # Create a full-fat Consultation to exercise the various different fields
  # and associated records that should be accommodated for when migrating.
  let(:consultation) do
    create(
      :published_consultation,
      # Attachments on the Consultation
      :with_alternative_format_provider,
      attachments: [
        build(:file_attachment),
        build(:html_attachment),
      ],

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

  before do
    stub_asset_downloads
  end

  it "converts a Consultation document into a Call for Evidence" do
    migrate

    # They have the same attributes
    ignore_attributes = %w[id type state auth_bypass_id minor_change change_note force_published lock_version]
    assert_equal consultation.attributes.except(*ignore_attributes),
                 call_for_evidence.attributes.except(*ignore_attributes)

    # and the same content
    assert_equal consultation.title, call_for_evidence.title
    assert_equal consultation.summary, call_for_evidence.summary
    assert_equal consultation.body, call_for_evidence.body

    # The document is in the state we expect it to be
    assert_equal 2, document.editions.count
    assert_instance_of CallForEvidence, document.latest_edition
    assert_equal "CallForEvidence", document.document_type
    assert consultation.published?
    assert call_for_evidence.draft?
  end

  it "converts the Consultation Outcome to a Call for Evidence Outcome" do
    migrate

    # Both outcomes have the same attributes
    ignore_attributes = %w[id edition_id type]
    assert_equal consultation.outcome.attributes.except(*ignore_attributes),
                 call_for_evidence.outcome.attributes.except(*ignore_attributes)
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

  describe "invalid documents" do
    context "when latest edition is not a consultation" do
      let(:consultation) { create(:published_news_story) }

      it "rejects the document" do
        assert_raises("Document cannot be migrated") { migrate }
      end
    end

    context "when the document has a draft edition" do
      before do
        consultation.create_draft(whodunnit)
      end

      it "rejects the document" do
        assert_raises("Document cannot be migrated") { migrate }
      end
    end
  end
end
