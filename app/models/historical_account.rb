class HistoricalAccount < ActiveRecord::Base
  belongs_to :person, inverse_of: :historical_accounts
  has_many   :historical_account_roles
  has_many   :roles, through: :historical_account_roles

  validates_with SafeHtmlValidator
  validates :person, :roles, :summary, :body, :political_parties, presence: true
  validates :born, :died, length: { maximum: 256 }
  validate :roles_support_historical_accounts

  serialize :political_party_ids, Array

  def self.for_role(role)
    includes(:historical_account_roles).where('historical_account_roles.role_id' => role)
  end

  def political_parties=(political_parties)
    political_parties ||= []
    self.political_party_ids = political_parties.collect(&:id)
  end

  def political_parties
    political_party_ids.collect { |id| PoliticalParty.find_by_id(id.to_i) }
  end

  def political_membership
    political_parties.collect(&:membership).to_sentence
  end

  def role
    roles.first
  end

  private

  def roles_support_historical_accounts
    unless roles.all? { |role| role.supports_historical_accounts? }
      errors.add(:base, 'The selected role(s) do not all support historical accounts')
    end
  end
end
