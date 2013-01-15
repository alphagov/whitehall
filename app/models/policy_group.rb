class PolicyGroup < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true, email_format: true
  validates :name, presence: true


  has_many :edition_policy_groups
  has_many :policies, through: :edition_policy_groups, source: :edition

  def has_summary?
    false
  end
end
