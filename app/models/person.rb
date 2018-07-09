class Person < ApplicationRecord
  include PublishesToPublishingApi
  include Searchable
  include MinisterialRole::MinisterialRoleReindexingConcern

  mount_uploader :image, ImageUploader, mount_on: :carrierwave_image

  has_many :role_appointments
  has_many :current_role_appointments,
           -> { where(RoleAppointment::CURRENT_CONDITION) },
           class_name: 'RoleAppointment'
  has_many :previous_role_appointments,
           -> { where.not(RoleAppointment::CURRENT_CONDITION) },
           class_name: 'RoleAppointment'
  has_many :speeches, through: :role_appointments
  has_many :news_articles, through: :role_appointments

  has_many :roles, through: :role_appointments
  has_many :current_roles, class_name: 'Role', through: :current_role_appointments, source: :role

  has_many :ministerial_roles, class_name: 'MinisterialRole', through: :role_appointments, source: :role
  has_many :current_ministerial_roles, class_name: 'MinisterialRole', through: :current_role_appointments, source: :role

  has_many :board_member_roles, class_name: 'BoardMemberRole', through: :role_appointments, source: :role
  has_many :current_board_member_roles, class_name: 'BoardMemberRole', through: :current_role_appointments, source: :role

  has_many :organisation_roles, through: :current_roles
  has_many :organisations, through: :organisation_roles

  has_many :historical_accounts, inverse_of: :person

  validates :name, presence: true
  validates_with SafeHtmlValidator

  validates_with ImageValidator, method: :image, size: [960, 640], if: :image_changed?

  searchable title: :name,
             link: :search_link,
             content: :biography_without_markup,
             description: :biography_without_markup,
             slug: :slug

  extend FriendlyId
  friendly_id :slug_name

  include TranslatableModel
  translates :biography

  delegate :url, to: :image, prefix: :image

  after_save :republish_organisation_to_publishing_api
  before_destroy :prevent_destruction_if_appointed
  after_update :touch_role_appointments

  def republish_organisation_to_publishing_api
    organisations.each(&:publish_to_publishing_api)
  end

  def published_policies
    Whitehall.search_client.search(
      filter_people: [slug],
      filter_format: "policy",
      order: "-public_timestamp"
    )["results"]
  end

  def search_link
    Whitehall.url_maker.person_path(slug)
  end

  def biography_without_markup
    Govspeak::Document.new(biography).to_text
  end

  def ministerial_roles_at(date)
    role_appointments_at(date).map(&:role).select { |role| role.is_a?(MinisterialRole) }
  end

  def role_appointments_at(date)
    role_appointments.where([
      ":date >= started_at AND (:date <= ended_at OR ended_at IS NULL)",
      { date: date }
    ])
  end

  def published_speeches
    speeches.latest_published_edition.in_reverse_chronological_order
  end

  def published_news_articles
    news_articles.latest_published_edition.in_reverse_chronological_order
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

  def previous_role_appointments
    (role_appointments - current_role_appointments).sort_by(&:started_at).reverse
  end

  def sort_key
    [surname, forename].compact.join(' ').downcase
  end

  def can_have_historical_accounts?
    roles.any?(&:supports_historical_accounts?)
  end

  def name_with_disambiguator
    role = current_roles.first
    role_name = role.try(:name)
    organisation = role.organisations.first.try(:name) if role

    [name, role_name, organisation].compact.join(' – ')
  end

private

  def name_as_words(*elements)
    elements.select(&:present?).join(' ')
  end

  def image_changed?
    changes["carrierwave_image"].present?
  end

  def slug_name
    prefix = forename.present? ? forename : title
    [prefix, surname].join(' ')
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
end
