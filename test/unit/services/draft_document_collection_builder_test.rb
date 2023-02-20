require "test_helper"

class DraftDocumentCollectionBuilderTest < ActiveSupport::TestCase
  setup do
    create(:user, email: assignee_email_address)
    create(:organisation, name: "Government Digital Service")

    # stub specialist topic
    stub_publishing_api_has_lookups({ specialist_topic_base_path => specialist_topic_content_id })
    stub_publishing_api_has_item(specialist_topic_content_item)

    # stub documents in specialist topic groups
    stub_publishing_api_has_item(whitehall_document_content_item)

    create(:document, content_id: whitehall_document_content_id, document_type: "detailed_guide")
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

    ## Adds documents to the groups
    document_collection_group_memberships = DocumentCollection.last.groups.flat_map(&:memberships)

    # documents that already exist in the whitehall database
    whitehall_document_member = document_collection_group_memberships.first
    assert_equal whitehall_document_member.document.content_id, whitehall_document_content_id
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

  def whitehall_document_content_id
    "aed2cee3-7ca8-4f00-ab17-9193fff516ae"
  end

  def whitehall_document_content_item
    { "title": "I am a whitehall document",
      "base_path": "/guidance/i-am-a-whitehall-document",
      "content_id": whitehall_document_content_id,
      "document_type": "detailed_guide",
      "publishing_app": "whitehall" }
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
            "content_ids": [
              whitehall_document_content_id,
            ],
          },
        ],
        "internal_name": "Benefits / Child Benefit",
      },
    }
  end
end
