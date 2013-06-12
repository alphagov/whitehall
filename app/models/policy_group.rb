class PolicyGroup < ActiveRecord::Base
  include Searchable

  validates :email, email_format: true, allow_blank: true
  validates :name, presence: true

  has_many :edition_policy_groups
  has_many :policies, through: :edition_policy_groups, source: :edition

  def has_summary?
    false
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
    raise NotImplementedError, '#search_link must be implemented in PolicyGroup subclasses, PolicyGroup can\'t be indexed directly.'
  end

end
