class DraftDocumentCollectionCreator
  GDS_CONTENT_ID = "af07d5a5-df63-4ddc-9383-6a666845ebe9".freeze

  attr_accessor :base_path, :assignee_email_address

  def self.call(*args)
    new(*args).perform!
  end

  def initialize(base_path, assignee_email_address)
    @base_path = base_path
    @assignee_email_address = assignee_email_address
  end

  def perform!
    return "Couldn't get the specialist topic" unless specialist_topic

    return "You can only copy over curated specialist topics" unless curated_specialist_topic?

    create_basic_document_collection
    # if can_perform?
    #   update_publishing_api!
    #   notify!
    #   true
    # end
  end

  # def failure_reason
  #   if !edition.pre_publication?
  #     "A #{edition.state} edition may not be updated."
  #   elsif !edition.valid?
  #     "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
  #   end
  # end
  #
  # def verb
  #   "create_draft_document_collection"
  # end
  #
  # def prepare_edition
  #   # TODO
  # end

private

  def create_basic_document_collection
    dc = DocumentCollection.create(
      title: specialist_topic[:title],
      summary: specialist_topic[:description],
      lead_organisations: [gds_organisation],
      creator: creator,
      previously_published: false,
      needs: [],
    )
    require 'pry'
    binding.pry
  end

  ## .get_links .get_expanded_links
  def creator
    User.find_by(email: assignee_email_address)
  end

  def gds_organisation
    Organisation.find_by(content_id: GDS_CONTENT_ID)
  end

  # def specialist_topic
  #   @specialist_topic ||= Services.publishing_api.get_content(content_id).to_h.deep_symbolize_keys
  # end

  def need_ids
    response = Services.publishing_api.get_links(content_id)

    return unless response

    response["links"]["meets_user_needs"]
  end

  def specialist_topic
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

  def curated_specialist_topic?
    specialist_topic[:details][:groups].present?
  end

  def content_id
    @content_id ||= Services.publishing_api.lookup_content_id(base_path:, with_drafts: true)
  end

end
