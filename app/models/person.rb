class Person < ApplicationRecord
  include PublishesToPublishingApi
  include ReshuffleMode

  has_many :role_appointments,
           lambda {
             (extending UserOrderableExtension).order(:ordering)
           }
  has_many :current_role_appointments,
           -> { where(RoleAppointment::CURRENT_CONDITION).order(:ordering) },
           class_name: "RoleAppointment"
  has_many :speeches, through: :role_appointments
  has_many :news_articles, through: :role_appointments

  has_many :roles, through: :role_appointments
  has_many :current_roles, class_name: "Role", through: :current_role_appointments, source: :role

  has_many :ministerial_roles, class_name: "MinisterialRole", through: :role_appointments, source: :role

  has_many :board_member_roles, class_name: "BoardMemberRole", through: :role_appointments, source: :role

  has_many :organisation_roles, through: :current_roles
  has_many :organisations, through: :organisation_roles

  has_one :historical_account, inverse_of: :person

  has_one :image, class_name: "FeaturedImageData", as: :featured_imageable, inverse_of: :featured_imageable

  accepts_nested_attributes_for :image, reject_if: :all_blank

  validates :name, presence: true
  validates_with SafeHtmlValidator

  extend FriendlyId
  friendly_id :slug_name

  include TranslatableModel
  translates :biography

  before_destroy :prevent_destruction_if_appointed
  after_update :touch_role_appointments, :republish_past_prime_ministers_page_to_publishing_api
  after_update :republish_ministerial_pages_to_publishing_api, if: :has_ministerial_appointments?

  def biography_without_markup
    Govspeak::Document.new(biography).to_text
  end

  def biography_appropriate_for_role
    if current_role_appointments.any?
      biography
    else
      truncated_biography
    end
  end

  def published_speeches
    speeches.live_edition.published.in_reverse_chronological_order
  end

  def published_news_articles
    news_articles.live_edition.published.in_reverse_chronological_order
  end

  def destroyable?
    role_appointments.empty?
  end

  def name
    name_as_words(("The Rt Hon" if privy_counsellor?), title, forename, surname, letters)
  end

  def full_name
    name_as_words(title, forename, surname, letters)
  end

  def name_without_privy_counsellor_prefix
    name_as_words(title, forename, surname, letters)
  end

  def sort_key
    [surname, forename].compact.join(" ").downcase
  end

  def can_have_historical_accounts?
    roles.any?(&:supports_historical_accounts?)
  end

  def name_with_disambiguator
    role = current_roles.first
    role_name = role.try(:name)
    organisation = role.organisations.first.try(:name) if role

    [name, role_name, organisation].compact.join(" – ")
  end

  def current_or_previous_prime_minister?
    ministerial_roles.map(&:slug).include?("prime-minister")
  end

  def base_path
    "/government/people/#{slug}"
  end

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    Plek.website_root + public_path(options)
  end

  def previous_dates_in_office_for_role(role)
    role_appointments.where(role:).historic.map do |appointment|
      {
        start_year: appointment.started_at.year,
        end_year: appointment.ended_at.year,
      }
    end
  end

  def current_role_appointments_title
    current_role_appointments.collect(&:role_name).to_sentence
  end

  def publishing_api_presenter
    PublishingApi::PersonPresenter
  end

  def republish_dependent_documents
    speeches.uniq { |speech| speech.document.id }.map { |speech| Whitehall::PublishingApi.republish_document_async(speech.document) }

    historical_account&.republish_to_publishing_api_async
  end

private

  def name_as_words(*elements)
    elements.select(&:present?).map(&:strip).join(" ")
  end

  def slug_name
    prefix = forename.presence || title
    [prefix, surname].join(" ")
  end

  def prevent_destruction_if_appointed
    throw :abort unless destroyable?
  end

  # Whenever a person is updated, we want touch the updated_at timestamps of
  # any associated role appointments so that the cache digest for the
  # taggable_ministerial_role_appointments_container gets invalidated.
  def touch_role_appointments
    role_appointments.update_all updated_at: Time.zone.now
  end

  def truncated_biography
    biography&.split(/\n/)&.first
  end

  def has_ministerial_appointments?
    role_appointments.any?(&:ministerial?)
  end

  def republish_past_prime_ministers_page_to_publishing_api
    if current_or_previous_prime_minister?
      historical_account.republish_to_publishing_api_async if historical_account.present?
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::HistoricalAccountsIndexPresenter")
    end
  end
end
