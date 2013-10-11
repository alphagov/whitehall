class PolicyTeam < PolicyGroup
  validates :email, presence: true

  def search_link
    Whitehall.url_maker.policy_team_path(slug)
  end
end
