class PolicyGroup < ApplicationRecord
  include Searchable
  include ::Attachable
  include PublishesToPublishingApi

  validates :email, email_format: true, allow_blank: true
  validates :name, presence: true

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :description

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

  def unpublished_edition
    nil
  end

  def published_policies
    Whitehall.search_client.search(
      filter_policy_groups: [slug],
      filter_format: "policy",
      order: "-public_timestamp",
    )["results"]
  end

  def has_summary?
    true
  end

  extend FriendlyId
  friendly_id

  def summary_or_name
    summary.presence || name
  end

  searchable title: :name,
             link: :search_link,
             content: :summary_or_name,
             description: :summary

  def search_link
    Whitehall.url_maker.policy_group_path(slug)
  end
end
