class PolicyTeam < PolicyGroup
  validates :email, presence: true, uniqueness: true

  def search_link
    policy_team_path(slug)
  end
end
