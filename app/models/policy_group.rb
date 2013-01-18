class PolicyGroup < ActiveRecord::Base
  validates :email, email_format: true, allow_blank: true
  validates :name, presence: true


  has_many :edition_policy_groups
  has_many :policies, through: :edition_policy_groups, source: :edition

  def has_summary?
    false
  end
end
