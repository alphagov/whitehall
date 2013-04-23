class Person < ActiveRecord::Base

  def self.columns
    # This is here to enable us to gracefully remove the biography column
    # in a future commit, *after* this change has been deployed
    super.reject { |column| ['biography'].include?(column.name) }
  end

  include Rails.application.routes.url_helpers
  include Searchable

  mount_uploader :image, ImageUploader, mount_on: :carrierwave_image

  has_many :role_appointments
  has_many :current_role_appointments, class_name: 'RoleAppointment', conditions: RoleAppointment::CURRENT_CONDITION
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

  validate :image_must_be_960px_by_640px, if: :image_changed?

  searchable title: :name,
             link: :search_link,
             content: :biography,
             only: :without_a_current_ministerial_role #Already covered by MinisterialRole

  extend FriendlyId
  friendly_id :slug_name

  include TranslatableModel
  translates :biography

  delegate :url, to: :image, prefix: :image

  before_destroy :prevent_destruction_if_appointed

  def search_link
    person_path(slug)
  end

  def self.without_a_current_ministerial_role
    includes(:current_roles).where("(#{RoleAppointment.arel_table[:id].eq(nil).to_sql}) OR (#{Role.arel_table[:type].not_eq("MinisterialRole").to_sql})")
  end

  def ministerial_roles_at(date)
    role_appointments_at(date).map(&:role).select { |role| role.is_a?(MinisterialRole) }
  end

  def role_appointments_at(date)
    role_appointments.where([
      ":date >= started_at AND (:date <= ended_at OR ended_at IS NULL)",
      {date: date}
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

  def name_without_privy_counsellor_prefix
    name_as_words(title, forename, surname, letters)
  end

  def previous_role_appointments
    role_appointments - current_role_appointments
  end

  def sort_key
    [surname, forename].compact.join(' ').downcase
  end

  private

  def name_as_words(*elements)
    elements.select do |word|
      word.present?
    end.join(' ')
  end

  def image_changed?
    changes["carrierwave_image"].present?
  end

  def image_must_be_960px_by_640px
    if image.path
      errors.add(:file, 'must be 960px wide and 640px tall') unless ImageSizeChecker.new(image.path).size_is?(960, 640)
    end
  end

  def slug_name
    prefix = forename.present? ? forename : title
    [prefix, surname].join(' ')
  end

  def prevent_destruction_if_appointed
    return false unless destroyable?
  end
end
