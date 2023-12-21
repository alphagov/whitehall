class HistoricalAccount < ApplicationRecord
  include PublishesToPublishingApi

  belongs_to :person, inverse_of: :historical_account
  has_one   :historical_account_role
  has_one   :role, through: :historical_account_role

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :body
  validates :person, :role, :summary, :body, :political_parties, presence: true
  validates :born, :died, length: { maximum: 256 }
  validate :roles_support_historical_accounts, if: -> { role.present? }
  validate :validate_correct_political_party
  after_save :republish_prime_ministers_index_page_to_publishing_api
  after_destroy :republish_prime_ministers_index_page_to_publishing_api

  serialize :political_party_ids, coder: YAML, type: Array

  def self.for_role(role)
    includes(:historical_account_roles).where("historical_account_roles.role_id" => role)
  end

  def political_party_ids=(ids)
    ids ||= []
    super(ids.reject(&:blank?))
  end

  def political_party_ids
    super || []
  end

  def political_parties
    political_party_ids.collect { |id| PoliticalParty.find_by_id(id.to_i) }
  end

  def political_parties=(political_parties)
    political_parties ||= []
    self.political_party_ids = political_parties.map(&:id)
  end

  def political_membership
    political_parties.collect(&:membership).to_sentence
  end

  def republish_prime_ministers_index_page_to_publishing_api
    PresentPageToPublishingApiWorker.perform_async("PublishingApi::HistoricalAccountsIndexPresenter") unless role.slug != "prime-minister"
  end

  def base_path
    "/government/history/past-prime-ministers/#{person.slug}" if previous_prime_minister?
  end

  def public_path(options = {})
    append_url_options(base_path, options) if previous_prime_minister?
  end

  def public_url(options = {})
    Plek.website_root + public_path(options) if previous_prime_minister?
  end

  def can_publish_to_publishing_api?
    super && previous_prime_minister?
  end

  def publishing_api_presenter
    PublishingApi::HistoricalAccountPresenter
  end

private

  def previous_prime_minister?
    role.slug == "prime-minister"
  end

  def roles_support_historical_accounts
    unless role.supports_historical_accounts?
      errors.add(:base, "The selected role does not support historical accounts")
    end
  end

  def validate_correct_political_party
    political_party_ids.each do |party_id|
      errors.add(:base, "No political party with an ID of #{party_id} exists.") if PoliticalParty.find_by_id(party_id.to_i).nil?
    end
  end
end
