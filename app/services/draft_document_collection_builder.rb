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

    ActiveRecord::Base.transaction do
      dc = initialise_document_collection
      add_groups_to_document_collection(dc)
      add_documents_to_groups(dc)
    end
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

  def add_groups_to_document_collection(document_collection)
    groups =
      specialist_topic_groups.map do |group|
        DocumentCollectionGroup.find_or_create_by!(
          document_collection_id: document_collection.id,
          heading: group[:name],
          body: "",
        )
      end
    document_collection.groups.replace(groups)
  end

  def add_documents_to_groups(document_collection)
    document_collection.groups.each do |group|
      add_documents_to_group(group)
    end
  end

  def add_documents_to_group(group)
    specialist_topic_groups.each do |topic_group|
      next if topic_group[:name] != group.heading

      topic_group[:content_ids].each do |content_id|
        if whitehall_document(content_id).present?

          DocumentCollectionGroupMembership.find_or_create_by!(
            document_id: whitehall_document(content_id).id,
            document_collection_group_id: group.id,
          )
        end
      end
    end
  end

  def specialist_topic_groups
    specialist_topic.dig(:details, :groups)
  end

  def whitehall_document(content_id)
    Document.find_by(content_id:)
  end

  def user
    @user ||= User.find_by(email: assignee_email_address)
  end

  def gds
    @gds ||= Organisation.find_by(name: "Government Digital Service")
  end
end
