class PolicyGroup < ApplicationRecord
  include Searchable
  include ::Attachable
  include PublishesToPublishingApi

  validates :email, email_format: true, allow_blank: true
  validates :name, presence: true

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :description

  has_many :policy_group_dependencies, dependent: :destroy
  has_many :depended_upon_contacts, through: :policy_group_dependencies, source: :dependable, source_type: "Contact"

  after_create :extract_dependencies
  after_update :extract_dependencies
  after_destroy :remove_all_dependencies, :delete_all_attachments
  after_update :publish_deleted_attachments

  def extract_dependencies
    remove_all_dependencies

    Govspeak::ContactsExtractor.new(description).contacts.uniq.each do |contact|
      PolicyGroupDependency.create(
        policy_group_id: id,
        dependable_type: "Contact",
        dependable_id: contact.id,
      )
    end
  end

  def publish_deleted_attachments
    deleted_attachments.each do |attachment|
      next unless attachment.attachment_data.present? && attachment.deleted?

      DeleteAttachmentAssetJob.perform_async(attachment.attachment_data.id)
    end
  end

  def remove_all_dependencies
    policy_group_dependencies.delete_all
  end

  def delete_all_attachments
    attachments.each do |attachment|
      attachment.destroy!

      next unless attachment.attachment_data

      DeleteAttachmentAssetJob.perform_async(attachment.attachment_data.id)
    end
  end

  def access_limited_object
    nil
  end

  def access_limited?
    false
  end

  def publicly_visible?
    true
  end

  def accessible_to?(*)
    true
  end

  def unpublished?
    false
  end

  def has_summary?
    true
  end

  def base_path
    "/government/groups/#{slug}"
  end

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    Plek.website_root + public_path(options)
  end

  extend FriendlyId
  friendly_id

  def summary_or_name
    summary.presence || name
  end

  searchable title: :name,
             link: :public_path,
             content: :summary_or_name,
             description: :summary

  def publishing_api_presenter
    PublishingApi::PolicyGroupPresenter
  end
end
