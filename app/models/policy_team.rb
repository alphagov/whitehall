class PolicyTeam < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true, email_format: true
  has_many :policies
end
