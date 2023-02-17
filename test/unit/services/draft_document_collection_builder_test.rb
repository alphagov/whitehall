require "test_helper"

class DraftDocumentCollectionBuilderTest < ActiveSupport::TestCase
  setup do
    create(:user, email: assignee_email_address)
    create(:organisation, name: "Government Digital Service")
    stub_publishing_api_has_lookups({ specialist_topic_base_path => specialist_topic_content_id })
    stub_publishing_api_has_item(specialist_topic_content_item)
  end

  test "perform! builds a document collection" do
    DraftDocumentCollectionBuilder.call(specialist_topic_base_path, assignee_email_address)

    # Adds basic attriubutes
    assert_equal 1, DocumentCollection.count
    assert_equal "Specialist topic import: #{specialist_topic_title}", DocumentCollection.last.title
    assert_equal specialist_topic_description, DocumentCollection.last.summary

    # Adds groups
    specialist_topic_group_names = specialist_topic_content_item[:details][:groups].map { |group| group[:name] }
    document_collection_group_names = DocumentCollection.last.groups.map(&:heading)

    assert_equal specialist_topic_group_names, document_collection_group_names
  end

  def assignee_email_address
    "my_email@email.com"
  end

  def specialist_topic_base_path
    "/topic/benefits-credits/child-benefit"
  end

  def specialist_topic_content_id
    "cc9eb8ab-7701-43a7-a66d-bdc5046224c0"
  end

  def specialist_topic_title
    "Child Benefit"
  end

  def specialist_topic_description
    "List of information about Child Benefit."
  end

  def specialist_topic_content_item
    {
      "base_path": specialist_topic_base_path,
      "content_id": specialist_topic_content_id,
      "document_type": "topic",
      "first_published_at": "2015-08-11T15:09:55.000+00:00",
      "locale": "en",
      "phase": "live",
      "public_updated_at": "2022-12-21T09:00:23.000+00:00",
      "publishing_app": "collections-publisher",
      "rendering_app": "collections",
      "schema_name": "topic",
      "title": specialist_topic_title,
      "updated_at": "2023-01-20T09:32:23.129Z",
      "publishing_request_id": "21965-1671613223.779-10.13.5.112-545",
      "links": {},
      "description": specialist_topic_description,
      "details": {
        "groups": [
          {
            "name": "How to claim",
            "content_ids": %w[
              aed2cee3-7ca8-4f00-ab17-9193fff516ae
              0ed58e79-d9f6-4bed-bbe4-c6b5bad1a543
              e2644b6d-2c90-47e3-89b7-bf69be25465b
            ],
          },
          {
            "name": "Payments",
            "content_ids": %w[
              0e1de8f1-9909-4e45-a6a3-bffe95470275
              db4795d9-0f5b-49b7-8a7b-64e626d1caf1
            ],
          },
          {
            "name": "Report changes",
            "content_ids": %w[
              10e436e5-26e0-4462-913f-9a497f7e793e
              d1f5ed43-f482-4927-95f4-22ccbcfbc89f
              65d2d5b2-22c4-4cfc-9399-9f7bcd145561
              25920434-312a-4fb7-b391-757b9c64faa2
              5b5a2321-da86-4252-9d2c-9fa3f8e9bfa8
              a1aac09a-22ee-4e8f-b698-a350a0541a86
              824913d8-94b1-497a-8ee4-fa4c3599b19c
              2f76be61-dca7-48a1-aaed-72e3bbc24be0
            ],
          },
          {
            "name": "Overpayments",
            "content_ids": %w[
              51bc92b9-5f12-45c0-99c1-1f3bdea9e369
            ],
          },
          {
            "name": "Complaints",
            "content_ids": %w[
              a6c7e355-6c65-437d-a498-d1ac5c8dbcd2
            ],
          },
          {
            "name": "Forms and reference material",
            "content_ids": %w[
              5fe781fb-7631-11e4-a3cb-005056011aef
            ],
          },
        ],
        "internal_name": "Benefits / Child Benefit",
      },
    }
  end
end
