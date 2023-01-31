require "test_helper"

class DraftDocumentCollectionCreatorTest < ActiveSupport::TestCase
  # test "#perform! calls notify! without modifying the edition" do
  #   edition = create(:draft_edition)
  #   edition.freeze
  #   updater = DraftEditionUpdater.new(edition)
  #   updater.expects(:update_publishing_api!).once
  #   updater.expects(:notify!).once
  #
  #   updater.perform!
  # end

  test "cannot perform if edition is invalid" do
    user = create(:gds_editor, email: "john.smith@digital.cabinet-office.gov.uk")
    gds_org = create(:organisation, content_id: "af07d5a5-df63-4ddc-9383-6a666845ebe9")
    # edition = Edition.new
    # require 'pry'
    # binding.pry

    # pp "running"
    updater = DraftDocumentCollectionCreator.new("/topic/benefits-credits/child-benefit", "john.smith@digital.cabinet-office.gov.uk")
    # updater.expects(:notify!).never
    # updater.expects(:update_publishing_api!).never

    updater.perform!

    assert_equal creator.email, "john.smith@digital.cabinet-office.gov.uk"
    Edition.last
  end

  # test "cannot perform if edition is not draft" do
  #   edition = create(:published_edition)
  #   updater = DraftEditionUpdater.new(edition)
  #   updater.expects(:notify!).never
  #   updater.expects(:update_publishing_api!).never
  #
  #   updater.perform!
  # end

  def content_item
    { "auth_bypass_ids" => [],
      "base_path" => "/topic/benefits-credits/child-benefit",
      "content_store" => "live",
      "description" => "List of information about Child Benefit.",
      "details" =>
  { "groups" =>
    [{ "name" => "How to claim",
       "content_ids" => %w[aed2cee3-7ca8-4f00-ab17-9193fff516ae 0ed58e79-d9f6-4bed-bbe4-c6b5bad1a543 e2644b6d-2c90-47e3-89b7-bf69be25465b] },
     { "name" => "Payments", "content_ids" => %w[0e1de8f1-9909-4e45-a6a3-bffe95470275 db4795d9-0f5b-49b7-8a7b-64e626d1caf1] },
     { "name" => "Report changes",
       "content_ids" =>
       %w[10e436e5-26e0-4462-913f-9a497f7e793e
          d1f5ed43-f482-4927-95f4-22ccbcfbc89f
          65d2d5b2-22c4-4cfc-9399-9f7bcd145561
          25920434-312a-4fb7-b391-757b9c64faa2
          5b5a2321-da86-4252-9d2c-9fa3f8e9bfa8
          a1aac09a-22ee-4e8f-b698-a350a0541a86
          824913d8-94b1-497a-8ee4-fa4c3599b19c
          2f76be61-dca7-48a1-aaed-72e3bbc24be0] },
     { "name" => "Overpayments", "content_ids" => %w[51bc92b9-5f12-45c0-99c1-1f3bdea9e369] },
     { "name" => "Complaints", "content_ids" => %w[a6c7e355-6c65-437d-a498-d1ac5c8dbcd2] },
     { "name" => "Forms and reference material", "content_ids" => %w[5fe781fb-7631-11e4-a3cb-005056011aef] }],
    "internal_name" => "Benefits / Child Benefit" },
      "document_type" => "topic",
      "first_published_at" => "2015-08-11T15:09:55Z",
      "last_edited_at" => "2022-12-21T09:00:23Z",
      "phase" => "live",
      "public_updated_at" => "2022-12-21T09:00:23Z",
      "published_at" => "2022-12-21T09:00:23Z",
      "publishing_app" => "collections-publisher",
      "publishing_api_first_published_at" => "2016-03-08T11:29:25Z",
      "publishing_api_last_edited_at" => "2022-12-21T09:00:23Z",
      "redirects" => [],
      "rendering_app" => "collections",
      "routes" => [{ "path" => "/topic/benefits-credits/child-benefit", "type" => "exact" }, { "path" => "/topic/benefits-credits/child-benefit/latest", "type" => "exact" }],
      "schema_name" => "topic",
      "title" => "Child Benefit",
      "user_facing_version" => 16,
      "update_type" => "minor",
      "publication_state" => "published",
      "content_id" => "cc9eb8ab-7701-43a7-a66d-bdc5046224c0",
      "locale" => "en",
      "lock_version" => 16,
      "updated_at" => "2022-12-21T09:00:23Z",
      "state_history" =>
  { "12" => "superseded",
    "1" => "superseded",
    "2" => "superseded",
    "3" => "superseded",
    "10" => "superseded",
    "4" => "superseded",
    "6" => "superseded",
    "7" => "superseded",
    "5" => "superseded",
    "8" => "superseded",
    "9" => "superseded",
    "11" => "superseded",
    "13" => "superseded",
    "14" => "superseded",
    "15" => "superseded",
    "16" => "published" },
      "links" => {} }
  end

  def get_links
    # possibly get taxon
    { "content_id" => "cc9eb8ab-7701-43a7-a66d-bdc5046224c0",
      "links" =>
  { "parent" => %w[4505d908-89f2-4322-956b-29ac243c608b],
    "primary_publishing_organisation" => %w[af07d5a5-df63-4ddc-9383-6a666845ebe9],
    "taxons" => %w[7a1ba896-b85a-4137-81d9-ab05b7ce67dd] },
      "version" => 14 }
  end
end
