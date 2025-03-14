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
      updater.errors,
      ["Expected the following headers: Document type,New lead organisations,New supporting organisations,Slug. Detected: Foo,"],
    )

    raw_csv = <<~CSV
      Slug,Document type,New lead organisations,New supporting organisations
      some-slug,Publication,lead-organisation,supporting-organisation,some extra data here which should trip up the validator
    CSV
    updater = DataHygiene::BulkOrganisationUpdater.new(raw_csv)
    updater.validate
    assert_equal(
      updater.errors,
      ["Exactly four fields expected. Detected: 5 ([\"some-slug\", \"Publication\", \"lead-organisation\", \"supporting-organisation\", \"some extra data here which should trip up the validator\"])"],
    )
  end

  test "it has a `validate` method that tracks invalid documents and organisations in the `errors` array" do
    raw_csv = <<~CSV
      Slug,Document type,New lead organisations,New supporting organisations
      some-slug,Publication,lead-organisation,supporting-organisation
    CSV

    updater = DataHygiene::BulkOrganisationUpdater.new(raw_csv)
    updater.validate

    assert_equal(
      updater.errors,
      [
        "Document not found: some-slug",
        "Organisation not found: lead-organisation",
        "Organisation not found: supporting-organisation",
      ],
    )
  end

  test "it has a `validate` method that returns empty `errors` array if no errors" do
    raw_csv = <<~CSV
      Slug,Document type,New lead organisations,New supporting organisations
      some-slug,Publication,lead-organisation,supporting-organisation
    CSV

    create(:document, document_type: "DetailedGuide", slug: "some-slug")
    create(:organisation, slug: "lead-organisation")
    create(:organisation, slug: "supporting-organisation")

    updater = DataHygiene::BulkOrganisationUpdater.new(raw_csv)
    updater.validate

    assert_equal(updater.errors, [])
  end

  test "it has a `summarise_changes` method that returns a hash summarising the changes" do
    raw_csv = <<~CSV
      Slug,Document type,New lead organisations,New supporting organisations
      some-slug,Publication,new-lead-organisation,new-supporting-organisation
      another-slug,Publication,"new-lead-organisation,old-lead-organisation"
      final-slug,Publication,old-lead-organisation,new-supporting-organisation
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

    assert_equal(updater.errors, [])
    assert_equal(
      updater.summarise_changes,
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

  test "it spots ambiguous slugs" do
    csv_file = <<~CSV
      Slug,Document type,New lead organisations,New supporting organisations
      shared-slug,,lead-organisation,
    CSV

    slug = "shared-slug"
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
    assert_equal(
      updater.errors,
      ["Ambiguous slug: shared-slug (document_types: [\"DetailedGuide\", \"Publication\"])"],
    )
  end

  test "it ignores the 'document type' field unless the 'slug' field is ambiguous" do
    csv_with_bad_document_type = <<~CSV
      Slug,Document type,New lead organisations,New supporting organisations
      shared-slug,"THIS DOCUMENT TYPE DOES NOT EXIST",lead-organisation,
    CSV

    csv_with_valid_document_type = <<~CSV
      Slug,Document type,New lead organisations,New supporting organisations
      shared-slug,CaseStudy,lead-organisation,
    CSV

    slug = "shared-slug"
    publication = create(:publication, document: build(:document, slug:))
    organisation = create(:organisation, slug: "lead-organisation")

    # it works when slug is unique, despite the invalid document type
    updater = process(csv_with_bad_document_type)
    assert_equal publication.lead_organisations, [organisation]

    # create two more documents with the same slug but different types
    case_study = create(:case_study, document: build(:document, slug:))
    news_article = create(:news_article, document: build(:document, slug:))

    # cannot find document with the specified document_type now that the slug is ambiguous
    updater.validate
    assert_equal(updater.errors, ["Document not found: shared-slug"])

    # it works when the CSV specifies a valid document type
    process(csv_with_valid_document_type)
    assert_equal case_study.lead_organisations, [organisation]
    assert_not_equal news_article.lead_organisations, [organisation]
  end

  test "it changes the lead organisations" do
    csv_file = <<~CSV
      Slug,Document type,New lead organisations,New supporting organisations
      this-is-a-slug,,lead-organisation,
    CSV

    document = create(:document, slug: "this-is-a-slug")
    edition = create(:published_publication, document:)
    organisation = create(:organisation, slug: "lead-organisation")

    process(csv_file)

    assert_equal edition.lead_organisations, [organisation]
    assert_equal PublishingApiDocumentRepublishingWorker.jobs.size, 1
    assert_equal PublishingApiDocumentRepublishingWorker.jobs.first["args"].first, document.id
  end

  test "it changes the supporting organisations" do
    csv_file = <<~CSV
      Slug,Document type,New lead organisations,New supporting organisations
      this-is-a-slug,,,"supporting-organisation-1,supporting-organisation-2"
    CSV

    document = create(:document, slug: "this-is-a-slug")
    edition = create(:published_publication, document:)
    organisation1 = create(:organisation, slug: "supporting-organisation-1")
    organisation2 = create(:organisation, slug: "supporting-organisation-2")

    process(csv_file)

    assert_equal edition.supporting_organisations, [organisation1, organisation2]
    assert_equal PublishingApiDocumentRepublishingWorker.jobs.size, 1
    assert_equal PublishingApiDocumentRepublishingWorker.jobs.first["args"].first, document.id
  end

  test "it just updates the draft when there is not a change to the published edition" do
    csv_file = <<~CSV
      Slug,Document type,New lead organisations,New supporting organisations
      this-is-a-slug,,lead-organisation,
    CSV

    document = create(:document, slug: "this-is-a-slug")
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

    assert_equal draft_edition.lead_organisations, [organisation]
    assert_equal PublishingApiDocumentRepublishingWorker.jobs.size, 0
  end

  test "it doesn't change a document which has already changed" do
    csv_file = <<~CSV
      Slug,Document type,New lead organisations,New supporting organisations
      this-is-a-slug,,lead-organisation,"supporting-organisation-1,supporting-organisation-2"
    CSV

    lead_organisation = create(:organisation, slug: "lead-organisation")
    supporting_organisation1 = create(:organisation, slug: "supporting-organisation-1")
    supporting_organisation2 = create(:organisation, slug: "supporting-organisation-2")
    document = create(:document, slug: "this-is-a-slug")
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

    assert_equal PublishingApiDocumentRepublishingWorker.jobs.size, 0
  end

  test "it processes Statistics Announcements" do
    csv_file = <<~CSV
      Slug,Document type,New lead organisations,New supporting organisations
      this-is-a-slug,StatisticsAnnouncement,lead-organisation,"supporting-organisation-1,supporting-organisation-2"
    CSV

    announcement = create(:statistics_announcement, slug: "this-is-a-slug")

    lead_organisation = create(:organisation, slug: "lead-organisation")
    supporting_organisation1 = create(:organisation, slug: "supporting-organisation-1")
    supporting_organisation2 = create(:organisation, slug: "supporting-organisation-2")

    Whitehall::PublishingApi.expects(:patch_links).with(announcement).once
    Whitehall::PublishingApi.expects(:publish).with(announcement).once

    process(csv_file)

    assert_equal [lead_organisation, supporting_organisation1, supporting_organisation2], announcement.reload.organisations
  end

  test "it doesn't change a Statistics Announcement which has already changed" do
    csv_file = <<~CSV
      Slug,Document type,New lead organisations,New supporting organisations
      this-is-a-slug,StatisticsAnnouncement,lead-organisation,"supporting-organisation-1,supporting-organisation-2"
    CSV

    lead_organisation = create(:organisation, slug: "lead-organisation")
    supporting_organisation1 = create(:organisation, slug: "supporting-organisation-1")
    supporting_organisation2 = create(:organisation, slug: "supporting-organisation-2")

    document = create(
      :statistics_announcement,
      slug: "this-is-a-slug",
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
