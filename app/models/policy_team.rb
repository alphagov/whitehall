class PolicyTeam < PolicyGroup
  validates :email, presence: true, uniqueness: true
end
