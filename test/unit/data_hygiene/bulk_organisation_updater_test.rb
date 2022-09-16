require "test_helper"

class DataHygiene::BulkOrganisationUpdaterTest < ActiveSupport::TestCase
  def process(csv_file)
    file = Tempfile.new("bulk_update_organisation")
    file.write(csv_file)
    file.close

    begin
      Sidekiq::Testing.fake! do
        DataHygiene::BulkOrganisationUpdater.call(file.path)
      end
    ensure
      file.unlink
    end
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

    assert_output(/ambiguous slug/) do
      process(csv_file)
    end
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

    process(csv_file)

    assert_equal PublishingApiDocumentRepublishingWorker.jobs.size, 0
  end
end
