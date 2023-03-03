class DraftDocumentCollectionBuilder
  def initialize(specialist_topic, assignee_email_address)
    @specialist_topic = specialist_topic
    @assignee_email_address = assignee_email_address
  end

  def self.call(*args)
    new(*args).perform!
  end

  def perform!
    raise "No user could be found for that email address" unless user

    initialise_document_collection
  end

private

  attr_reader :specialist_topic, :assignee_email_address

  def initialise_document_collection
    DocumentCollection.find_or_create_by!(
      mapped_specialist_topic_content_id: specialist_topic[:content_id],
    ) do |document_collection|
      document_collection.title = "Specialist topic import: #{specialist_topic[:title]}"
      document_collection.summary = specialist_topic[:description]
      document_collection.body = ""
      document_collection.creator = user
      document_collection.lead_organisations = [gds]
      document_collection.previously_published = false
      document_collection.state = "draft"
    end
  end

  def user
    @user ||= User.find_by(email: assignee_email_address)
  end

  def gds
    @gds ||= Organisation.find_by(name: "Government Digital Service")
  end
end
