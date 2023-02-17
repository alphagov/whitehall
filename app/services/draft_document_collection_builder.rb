class DraftDocumentCollectionBuilder
  def initialize(base_path, assignee_email_address)
    @base_path = base_path
    @assignee_email_address = assignee_email_address
  end

  def self.call(*args)
    new(*args).perform!
  end

  def perform!
    raise "No user could be found for that email address" unless user
    raise "You can only convert a curated specialist topic" unless curated_specialist_topic?

    ActiveRecord::Base.transaction do
      dc = initialise_document_collection
      add_groups_to_document_collection(dc)
    end
  end

private

  attr_reader :base_path, :assignee_email_address

  def initialise_document_collection
    DocumentCollection.find_or_create_by!(
      title: "Specialist topic import: #{specialist_topic[:title]}",
      summary: specialist_topic[:description],
    ) do |document_collection|
      document_collection.body = ""
      document_collection.creator = user
      document_collection.lead_organisations = [gds]
      document_collection.previously_published = false
      document_collection.state = "draft"
    end
  end

  def add_groups_to_document_collection(document_collection)
    groups =
      specialist_topic_groups.map.with_index do |group, i|
        DocumentCollectionGroup.create!(
          document_collection_id: document_collection.id,
          heading: group[:name],
          body: "",
          ordering: i,
        )
      end
    document_collection.groups.replace(groups)
  end

  def user
    @user ||= User.find_by(email: assignee_email_address)
  end

  def gds
    @gds ||= Organisation.find_by(name: "Government Digital Service")
  end

  def content_item(content_id)
    Services.publishing_api.get_content(content_id).to_h.deep_symbolize_keys
  rescue GdsApi::HTTPNotFound
    {}
  end

  def specialist_topic_content_id
    content_id = Services.publishing_api.lookup_content_id(base_path:)

    raise "Publishing API has no content with that base path" unless content_id

    content_id
  end

  def specialist_topic
    @specialist_topic ||= content_item(specialist_topic_content_id)
  end

  def curated_specialist_topic?
    specialist_topic_groups.present?
  end

  def specialist_topic_groups
    specialist_topic.dig(:details, :groups)
  end
end
