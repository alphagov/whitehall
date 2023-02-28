class HistoricalAccount < ApplicationRecord
  include PublishesToPublishingApi

  belongs_to :person, inverse_of: :historical_accounts
  has_many   :historical_account_roles
  has_many   :roles, through: :historical_account_roles

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :body
  validates :person, :roles, :summary, :body, :political_parties, presence: true
  validates :born, :died, length: { maximum: 256 }
  validate :roles_support_historical_accounts
  validate :validate_correct_political_party
  after_save :republish_prime_ministers_index_page_to_publishing_api
  after_destroy :republish_prime_ministers_index_page_to_publishing_api

  serialize :political_party_ids, Array

  def self.for_role(role)
    includes(:historical_account_roles).where("historical_account_roles.role_id" => role)
  end

  def political_party_ids=(ids)
    ids ||= []
    super(ids.reject(&:blank?))
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

  def role
    roles.first
  end

  def republish_prime_ministers_index_page_to_publishing_api
    PublishPrimeMinistersIndexPage.new.publish unless role.slug != "prime-minister"
  end

  def appointment_info_array
    [
      {
        title: "Born",
        text: born,
      },
      {
        title: "Died",
        text: died,
      },
      {
        title: "Dates in office",
        text: previous_dates_in_office,
      },
      {
        title: "Political party",
        text: political_membership,
      },
      {
        title: "Major acts",
        text: major_acts,
      },
      {
        title: "Interesting facts",
        text: interesting_facts,
      },
    ]
  end

  def previous_dates_in_office
    role.previous_appointments.for_person(person)
         .map { |r| RoleAppointmentPresenter.new(r, self).date_range }
         .join(", ")
  end

  def base_path
    "/government/history/past-prime-ministers/#{person.slug}" if previous_prime_minister?
  end

  def public_path(options = {})
    append_url_options(base_path, options, locale: :en) if previous_prime_minister?
  end

  def public_url(options = {})
    Plek.website_root + public_path(options) if previous_prime_minister?
  end

  def can_publish_to_publishing_api?
    super && previous_prime_minister?
  end

private

  def previous_prime_minister?
    roles.map(&:slug).include?("prime-minister")
  end

  def roles_support_historical_accounts
    unless roles.all?(&:supports_historical_accounts?)
      errors.add(:base, "The selected role(s) do not all support historical accounts")
    end
  end

  def validate_correct_political_party
    political_party_ids.each do |party_id|
      errors.add(:base, "No political party with an ID of #{party_id} exists.") if PoliticalParty.find_by_id(party_id.to_i).nil?
    end
  end
end
