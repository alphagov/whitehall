class Person < ActiveRecord::Base
  mount_uploader :image, PersonImageUploader, mount_on: :carrierwave_image

  has_many :role_appointments
  has_many :current_role_appointments, class_name: 'RoleAppointment', conditions: RoleAppointment::CURRENT_CONDITION

  has_many :roles, through: :role_appointments
  has_many :current_roles, class_name: 'Role', through: :current_role_appointments, source: :role

  has_many :ministerial_roles, class_name: 'MinisterialRole', through: :role_appointments, source: :role
  has_many :current_ministerial_roles, class_name: 'MinisterialRole', through: :current_role_appointments, source: :role

  has_many :board_member_roles, class_name: 'BoardMemberRole', through: :role_appointments, source: :role
  has_many :current_board_member_roles, class_name: 'BoardMemberRole', through: :current_role_appointments, source: :role

  has_many :organisation_roles, through: :ministerial_roles
  has_many :organisations, through: :organisation_roles

  validates :name, presence: true

  extend FriendlyId
  friendly_id :slug_name, use: :slugged

  delegate :url, to: :image, prefix: :image

  before_destroy :prevent_destruction_if_appointed

  def destroyable?
    role_appointments.empty?
  end

  def image_filename
    image_url && File.basename(image_url)
  end

  def name
    [title, forename, surname, letters].reject(&:blank?).join(' ')
  end

  def to_s
    name
  end

  def previous_role_appointments
    role_appointments - current_role_appointments
  end

  private

  def slug_name
    prefix = forename.present? ? forename : title
    [prefix, surname].join(' ')
  end

  def prevent_destruction_if_appointed
    return false unless destroyable?
  end
end