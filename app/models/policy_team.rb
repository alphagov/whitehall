# == Schema Information
#
# Table name: policy_groups
#
#  id          :integer          not null, primary key
#  email       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  name        :string(255)
#  description :text
#  type        :string(255)
#  summary     :text
#  slug        :string(255)
#

class PolicyTeam < PolicyGroup
  validates :email, presence: true, uniqueness: true

  def search_link
    Whitehall.url_maker.policy_team_path(slug)
  end
end
