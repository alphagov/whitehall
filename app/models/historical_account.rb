class HistoricalAccount < ActiveRecord::Base
  belongs_to :person, inverse_of: :historical_accounts
  has_many   :historical_account_roles
  has_many   :roles, through: :historical_account_roles

  validates_with SafeHtmlValidator
  validates :person, :roles, :summary, :body, :political_party, presence: true
  validates :born, :died, length: { maximum: 256 }

  def political_party=(political_party)
    self.political_party_id = political_party.try(:id)
  end

  def political_party
    PoliticalParty.find_by_id(political_party_id)
  end

  def political_membership
    political_party.try(:membership)
  end
end
