require "test_helper"

class DraftDocumentCollectionBuilderTest < ActiveSupport::TestCase
  include SpecialistTopicHelper

  setup do
    create(:user, email: assignee_email_address)
    create(:organisation, name: "Government Digital Service")

    document = create(:document, content_id: whitehall_document_content_id, document_type: "DetailedGuide")
    create(:published_detailed_guide, document_id: document.id, type: "DetailedGuide")

    collection = create(:document, content_id: document_collection_content_id, document_type: "DocumentCollection")
    create(:published_document_collection, document_id: collection.id, type: "DocumentCollection")
  end

  test "#perform! builds basic document collection" do
    stub_valid_specialist_topic
    DraftDocumentCollectionBuilder.call(specialist_topic_content_item, assignee_email_address)

    # Adds basic attributes
    assert_equal 2, DocumentCollection.count
    assert_equal specialist_topic_content_item[:content_id], DocumentCollection.last.mapped_specialist_topic_content_id
    assert_equal DocumentCollection.last.title, "Specialist topic import: #{specialist_topic_title}"
    assert_equal specialist_topic_description, DocumentCollection.last.summary

    # Adds groups
    specialist_topic_group_names = specialist_topic_content_item[:details][:groups].map { |group| group[:name] }
    document_collection_group_names = DocumentCollection.last.groups.map(&:heading)

    assert_equal specialist_topic_group_names, document_collection_group_names

    # Adds documents to the groups
    document_collection_group_memberships = DocumentCollection.last.groups.flat_map(&:memberships)

    # Documents that already exist in the Whitehall database
    whitehall_document_member = document_collection_group_memberships.first
    assert_equal whitehall_document_member.document.content_id, whitehall_document_content_id

    # Documents that were not published by Whitehall
    non_whitehall_document_member = document_collection_group_memberships.second
    non_whitehall_link = DocumentCollectionNonWhitehallLink.find_by(base_path: non_whitehall_document_content_item[:base_path])
    assert_equal non_whitehall_document_member.non_whitehall_link_id, non_whitehall_link.id

    # Document collections
    document_collection_member = document_collection_group_memberships.third
    document_collection_link = DocumentCollectionNonWhitehallLink.find_by(base_path: document_collection_content_item[:base_path])
    assert_equal document_collection_member.non_whitehall_link_id, document_collection_link.id
  end

  test "#perform! will not add unpublished documents to a document collection group membership" do
    stub_valid_specialist_topic_with_unpublished_links

    document = create(:document, content_id: unpublished_document_content_id, document_type: "Publication")
    create(:edition, :unpublished, type: "Publication", document_id: document.id)

    DraftDocumentCollectionBuilder.call(specialist_topic_with_unpublished_links_content_item, assignee_email_address)

    group = DocumentCollection.last.groups.first
    members = group.memberships
    assert_equal 0, members.count

    # And will not query publishing api about the state of Whitehall documents
    @publishing_api_endpoint = GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT

    assert_publishing_api(:get, "#{@publishing_api_endpoint}/content/#{unpublished_non_whitehall_document_content_id}")
    assert_not_requested stub_publishing_api_has_item(unpublished_document_content_item)
  end

  test "#perform! will not update a document collection that has been published" do
    create(:published_document_collection, mapped_specialist_topic_content_id: specialist_topic_content_id)
    exception = assert_raises(Exception) { DraftDocumentCollectionBuilder.call(specialist_topic_content_item, assignee_email_address) }
    assert_equal("Specialist topic has already been converted and published", exception.message)
  end

  test "#perform! fails unless a user is present" do
    exception = assert_raises(Exception) { DraftDocumentCollectionBuilder.call(specialist_topic_content_item, "no-one@email.co.uk") }
    assert_equal("No user could be found for that email address", exception.message)
  end

  def assignee_email_address
    "my_email@email.com"
  end
end
