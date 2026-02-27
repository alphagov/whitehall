require "test_helper"

class DataHygiene::BulkOrganisationUpdaterTest < ActiveSupport::TestCase
  def process(raw_csv)
    updater = DataHygiene::BulkOrganisationUpdater.new(raw_csv)

    Sidekiq::Testing.fake! do
      updater.call
    end

    updater
  end

  test "it has a `validate` method that tracks invalid inputs as an `errors` array" do
    raw_csv = <<~CSV
      Foo,

      bar,baz
    CSV
    updater = DataHygiene::BulkOrganisationUpdater.new(raw_csv)
    updater.validate
    assert_equal(
      ["Expected the following headers: URL,Lead organisations,Supporting organisations. Detected: Foo,"],
      updater.errors,
    )

    raw_csv = <<~CSV
      URL,Lead organisations,Supporting organisations
      https://www.gov.uk/government/publications/some-slug,lead-organisation,supporting-organisation,some extra data here which should trip up the validator
    CSV
    updater = DataHygiene::BulkOrganisationUpdater.new(raw_csv)
    updater.validate
    assert_equal(
      ["Exactly three fields expected. Detected: 4 ([\"https://www.gov.uk/government/publications/some-slug\", \"lead-organisation\", \"supporting-organisation\", \"some extra data here which should trip up the validator\"])"],
      updater.errors,
    )
  end

  test "it has a `validate` method that tracks invalid documents and organisations in the `errors` array" do
    raw_csv = <<~CSV
      URL,Lead organisations,Supporting organisations
      https://www.gov.uk/government/publications/some-slug,lead-organisation,supporting-organisation
    CSV

    updater = DataHygiene::BulkOrganisationUpdater.new(raw_csv)
    updater.validate

    assert_equal(
      [
        "Document not found: https://www.gov.uk/government/publications/some-slug",
        "Organisation not found: lead-organisation",
        "Organisation not found: supporting-organisation",
      ],
      updater.errors,
    )
  end

  test "has a `validate` method that flags any HTML attachments in the `errors` array" do
    raw_csv = <<~CSV
      URL,Lead organisations,Supporting organisations
      https://www.gov.uk/government/publications/foo/bar,lead-organisation,
    CSV
    create(:organisation, slug: "lead-organisation")

    updater = DataHygiene::BulkOrganisationUpdater.new(raw_csv)
    updater.validate

    assert_equal(
      ["URL points to a HtmlAttachment, not a document: https://www.gov.uk/government/publications/foo/bar. HTML attachments should not be included here - they will instead inherit any changes made to their parent document."],
      updater.errors,
    )
  end

  test "it has a `validate` method that returns empty `errors` array if no errors" do
    raw_csv = <<~CSV
      URL,Lead organisations,Supporting organisations
      https://www.gov.uk/guidance/some-slug,lead-organisation,supporting-organisation
    CSV

    create(:document, document_type: "DetailedGuide", slug: "some-slug")
    create(:organisation, slug: "lead-organisation")
    create(:organisation, slug: "supporting-organisation")

    updater = DataHygiene::BulkOrganisationUpdater.new(raw_csv)
    updater.validate

    assert_equal([], updater.errors)
  end

  test "it has a `summarise_changes` method that returns a hash summarising the changes" do
    raw_csv = <<~CSV
      URL,Lead organisations,Supporting organisations
      https://www.gov.uk/government/publications/some-slug,new-lead-organisation,new-supporting-organisation
      https://www.gov.uk/government/publications/another-slug,"new-lead-organisation,old-lead-organisation"
      https://www.gov.uk/government/publications/final-slug,old-lead-organisation,new-supporting-organisation
    CSV

    old_lead_org = create(:organisation, slug: "old-lead-organisation")
    new_lead_org = create(:organisation, slug: "new-lead-organisation")
    create(:organisation, slug: "new-supporting-organisation")
    old_supporting_org = create(:organisation, slug: "old-supporting-organisation")

    doc1 = create(:document, slug: "some-slug")
    create(
      :publication,
      :published,
      document: doc1,
      lead_organisations: [old_lead_org],
      supporting_organisations: [old_supporting_org],
    )
    doc2 = create(:document, slug: "another-slug")
    create(
      :publication,
      :published,
      document: doc2,
      lead_organisations: [old_lead_org, new_lead_org],
      supporting_organisations: [old_supporting_org],
    )
    doc3 = create(:document, slug: "final-slug")
    create(
      :publication,
      :published,
      document: doc3,
      lead_organisations: [old_lead_org],
      supporting_organisations: [],
    )

    updater = DataHygiene::BulkOrganisationUpdater.new(raw_csv)
    updater.validate

    assert_equal([], updater.errors)
    assert_equal(
      [
        {
          slug: "some-slug",
          lead_orgs_summary: "Added new-lead-organisation, Removed old-lead-organisation. Result: new-lead-organisation",
          supporting_orgs_summary: "Added new-supporting-organisation, Removed old-supporting-organisation. Result: new-supporting-organisation",
        },
        {
          slug: "another-slug",
          lead_orgs_summary: "Reordered (from old-lead-organisation, new-lead-organisation). Result: new-lead-organisation, old-lead-organisation",
          supporting_orgs_summary: "Removed old-supporting-organisation. Result: ",
        },
        {
          slug: "final-slug",
          lead_orgs_summary: "Unchanged. Result: old-lead-organisation",
          supporting_orgs_summary: "Added new-supporting-organisation. Result: new-supporting-organisation",
        },
      ],
      updater.summarise_changes,
    )
  end

  test "it fails with invalid CSV data" do
    csv_file = <<~CSV
      document slug,document type,new lead organisation,supporting organisations
      this-is-a-slug,,new-organisation,new-supporting-organisation
    CSV

    assert_raises KeyError do
      process(csv_file)
    end
  end

  test "it correctly maps the slug to the document type" do
    csv_file = <<~CSV
      URL,Lead organisations,Supporting organisations
      https://www.gov.uk/guidance/uk-ncp-complaint-handling-process,lead-organisation,
    CSV

    slug = "uk-ncp-complaint-handling-process"
    create(
      :document,
      document_type: "DetailedGuide",
      slug:,
    )
    create(
      :document,
      document_type: "Publication",
      slug:,
    )
    create(:organisation, slug: "lead-organisation")

    updater = process(csv_file)
    updater.validate

    assert_equal([], updater.errors)
  end

  test "it changes the lead organisations" do
    csv_file = <<~CSV
      URL,Lead organisations,Supporting organisations
      https://www.gov.uk/government/publications/some-slug,lead-organisation,
    CSV

    document = create(:document, slug: "some-slug")
    edition = create(:published_publication, document:)
    organisation = create(:organisation, slug: "lead-organisation")

    process(csv_file)

    assert_equal [organisation], edition.reload.lead_organisations
    assert_equal 1, PublishingApiDocumentRepublishingJob.jobs.size
    assert_equal document.id, PublishingApiDocumentRepublishingJob.jobs.first["args"].first
  end

  test "it changes the supporting organisations" do
    csv_file = <<~CSV
      URL,Lead organisations,Supporting organisations
      https://www.gov.uk/government/publications/some-slug,"lead-organisation-1","supporting-organisation-1,supporting-organisation-2"
    CSV

    document = create(:document, slug: "some-slug")
    edition = create(:published_publication, document:)
    create(:organisation, slug: "lead-organisation-1")
    organisation1 = create(:organisation, slug: "supporting-organisation-1")
    organisation2 = create(:organisation, slug: "supporting-organisation-2")

    process(csv_file)

    assert_equal [organisation1, organisation2], edition.reload.supporting_organisations
    assert_equal 1, PublishingApiDocumentRepublishingJob.jobs.size
    assert_equal document.id, PublishingApiDocumentRepublishingJob.jobs.first["args"].first
  end

  test "it just updates the draft when there is not a change to the published edition" do
    csv_file = <<~CSV
      URL,Lead organisations,Supporting organisations
      https://www.gov.uk/government/publications/some-slug,lead-organisation,
    CSV

    document = create(:document, slug: "some-slug")
    organisation = create(:organisation, slug: "lead-organisation")
    create(
      :published_publication,
      document:,
      lead_organisations: [organisation],
    )
    draft_edition = create(
      :draft_publication,
      document:,
    )

    Whitehall::PublishingApi.expects(:save_draft).once

    process(csv_file)

    assert_equal [organisation], draft_edition.reload.lead_organisations
    assert_equal 0, PublishingApiDocumentRepublishingJob.jobs.size
  end

  # TODO: this one seems to pass no matter what I set at the CSV file 🤔
  test "it doesn't change a document which has already changed" do
    csv_file = <<~CSV
      URL,Lead organisations,Supporting organisations
      https://www.gov.uk/government/publications/some-slug,,,lead-organisation,"supporting-organisation-1,supporting-organisation-2"
    CSV

    lead_organisation = create(:organisation, slug: "lead-organisation")
    supporting_organisation1 = create(:organisation, slug: "supporting-organisation-1")
    supporting_organisation2 = create(:organisation, slug: "supporting-organisation-2")
    document = create(:document, slug: "some-slug")
    create(
      :publication,
      document:,
      lead_organisations: [lead_organisation],
      supporting_organisations: [supporting_organisation1, supporting_organisation2],
    )

    document_stub = Minitest::Mock.new
    document_stub.expect(:update, nil) { raise "update was called when it shouldn't have been!" }
    document.stub(:update, document_stub) do
      process(csv_file)
    end

    assert_equal 0, PublishingApiDocumentRepublishingJob.jobs.size
  end

  test "it processes Statistics Announcements" do
    csv_file = <<~CSV
      URL,Lead organisations,Supporting organisations
      http://gov.uk/government/statistics/announcements/slug,lead-organisation,"supporting-organisation-1,supporting-organisation-2"
    CSV

    announcement = create(:statistics_announcement, slug: "slug")

    lead_organisation = create(:organisation, slug: "lead-organisation")
    supporting_organisation1 = create(:organisation, slug: "supporting-organisation-1")
    supporting_organisation2 = create(:organisation, slug: "supporting-organisation-2")

    Whitehall::PublishingApi.expects(:patch_links).with(announcement).once
    Whitehall::PublishingApi.expects(:publish).with(announcement).once

    process(csv_file)

    assert_equal announcement.reload.organisations, [lead_organisation, supporting_organisation1, supporting_organisation2]
  end

  test "it processes Standard Editions" do
    csv_file = <<~CSV
      URL,Lead organisations,Supporting organisations
      https://www.gov.uk/government/news/some-slug,lead-organisation,
    CSV

    document = create(:document, slug: "some-slug")
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type(
                                                "test_type", {
                                                  "associations" => [{ "key" => "organisations" }],
                                                  "settings" => { "base_path_prefix" => "/government/news" },
                                                }
                                              ))
    standard_edition = build(:standard_edition, document:)
    standard_edition.edition_organisations.build([{ organisation: create(:organisation), lead: true }])
    standard_edition.save!

    organisation = create(:organisation, slug: "lead-organisation")

    process(csv_file)

    assert_equal [organisation], standard_edition.reload.lead_organisations
  end

  test "it doesn't change a Statistics Announcement which has already changed" do
    csv_file = <<~CSV
      URL,Lead organisations,Supporting organisations
      http://gov.uk/government/statistics/announcements/slug,lead-organisation,"supporting-organisation-1,supporting-organisation-2"
    CSV

    lead_organisation = create(:organisation, slug: "lead-organisation")
    supporting_organisation1 = create(:organisation, slug: "supporting-organisation-1")
    supporting_organisation2 = create(:organisation, slug: "supporting-organisation-2")

    document = create(
      :statistics_announcement,
      slug: "slug",
      organisations: [lead_organisation, supporting_organisation1, supporting_organisation2],
    )

    Whitehall::PublishingApi.expects(:patch_links).never
    Whitehall::PublishingApi.expects(:publish).never

    document_stub = Minitest::Mock.new
    document_stub.expect(:update, nil) { raise "update was called when it shouldn't have been!" }
    document.stub(:update, document_stub) do
      process(csv_file)
    end
  end
end
