class PolicyTeam < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true, email_format: true
  validates :name, presence: true
  has_many :policies
end
