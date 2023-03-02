require "test_helper"

class DraftDocumentCollectionBuilderTest < ActiveSupport::TestCase
  include SpecialistTopicHelper

  setup do
    create(:user, email: assignee_email_address)
    create(:organisation, name: "Government Digital Service")
  end

  test "#perform! builds basic document collection" do
    stub_valid_specialist_topic

    DraftDocumentCollectionBuilder.call(specialist_topic_content_item, assignee_email_address)

    # Adds basic attributes
    assert_equal 1, DocumentCollection.count
    assert_equal specialist_topic_content_item[:content_id], DocumentCollection.last.mapped_specialist_topic_content_id
    assert_equal DocumentCollection.last.title, "Specialist topic import: #{specialist_topic_title}"
    assert_equal specialist_topic_description, DocumentCollection.last.summary

    # Adds groups
    specialist_topic_group_names = specialist_topic_content_item[:details][:groups].map { |group| group[:name] }
    document_collection_group_names = DocumentCollection.last.groups.map(&:heading)

    assert_equal specialist_topic_group_names, document_collection_group_names
  end

  test "#perform! fails unless a user is present" do
    exception = assert_raises(Exception) { DraftDocumentCollectionBuilder.call(specialist_topic_content_item, "no-one@email.co.uk") }
    assert_equal("No user could be found for that email address", exception.message)
  end

  def assignee_email_address
    "my_email@email.com"
  end
end
