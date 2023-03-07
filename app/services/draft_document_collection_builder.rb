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
      confirm_valid_for_conversion(dc)
      add_groups_to_document_collection(dc)
      add_documents_to_groups(dc)
    end
  end

private

  attr_reader :specialist_topic, :assignee_email_address

  def confirm_valid_for_conversion(edition)
    message = "Specialist topic has already been converted and published"

    confirm_latest_edition(edition, message)
    confirm_draft(edition, message)
  end

  def confirm_latest_edition(edition, message)
    parent_document = edition.document

    raise message unless parent_document.latest_edition.id == edition.id
  end

  def confirm_draft(edition, message)
    raise message if edition.document.live?
  end

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
        if permissable_whitehall_document(content_id).present?
          build_document_group_membership(permissable_whitehall_document(content_id), group)
        else
          build_non_whitehall_link(group, content_id)
        end
      end
    end
  end

  def specialist_topic_groups
    specialist_topic.dig(:details, :groups)
  end

  def permissable_whitehall_document(content_id)
    document = Document.find_by(content_id:)

    return if document&.document_type == "DocumentCollection"

    document
  end

  def build_document_group_membership(document, group)
    return unless document.live?

    DocumentCollectionGroupMembership.find_or_create_by!(
      document_id: document.id,
      document_collection_group_id: group.id,
    )
  end

  def dead_link?(content_item)
    content_item[:unpublishing].present?
  end

  # only govuk pages can be tagged to a specialist topic. So we can safely
  # assume that any non-whitehall links present in a specialist topic will
  # be internal URLs.
  def build_non_whitehall_link(group, content_id)
    content_item_hash = content_item(content_id)

    return if dead_link?(content_item_hash)

    link = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk#{content_item_hash[:base_path]}",
      document_collection_group: group,
    )
    if !link.save && link.errors.any?
      raise link.errors.messages.to_s
    end
  end

  def user
    @user ||= User.find_by(email: assignee_email_address)
  end

  def gds
    @gds ||= Organisation.find_by(name: "Government Digital Service")
  end

  def content_item(content_id)
    Services.publishing_api.get_content(content_id).to_h.deep_symbolize_keys
  end
end
