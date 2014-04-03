class PolicyGroup < ActiveRecord::Base
  include Searchable
  include ::Attachable

  validates :email, email_format: true, allow_blank: true
  validates :name, presence: true

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :description

  has_many :edition_policy_groups
  has_many :policies, through: :edition_policy_groups, source: :edition

  def has_summary?
    true
  end

  extend FriendlyId
  friendly_id

  def summary_or_name
    summary.present? ? summary : name
  end

  searchable title: :name,
             link: :search_link,
             content: :summary_or_name,
             description: :summary

  def search_link
    Whitehall.url_maker.policy_group_path(slug)
  end
end
