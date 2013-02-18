class Person < ActiveRecord::Base
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

  validates :name, presence: true
  validates_with SafeHtmlValidator

  validate :image_must_be_960px_by_640px, if: :image_changed?

  extend FriendlyId
  friendly_id :slug_name

  delegate :url, to: :image, prefix: :image

  before_destroy :prevent_destruction_if_appointed

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
    image_file = image && image.path && MiniMagick::Image.open(image.path)
    unless image_file.nil? || (image_file[:width] == 960 && image_file[:height] == 640)
      errors.add(:image, "must be 960px wide and 640px tall")
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
