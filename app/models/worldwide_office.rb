class WorldwideOffice < ActiveRecord::Base
  PRIMARY_ROLES = [AmbassadorRole, HighCommissionerRole, GovernorRole]

  has_many :worldwide_office_world_locations, dependent: :destroy
  has_many :world_locations, through: :worldwide_office_world_locations
  has_many :contacts, as: :contactable, dependent: :destroy
  has_many :social_media_accounts, as: :socialable, dependent: :destroy
  has_many :sponsorships, dependent: :destroy
  has_many :sponsoring_organisations, through: :sponsorships, source: :organisation
  belongs_to :main_contact, class_name: 'Contact'
  has_many :worldwide_office_roles
  has_many :roles, through: :worldwide_office_roles
  has_many :people, through: :roles

  alias :original_main_contact :main_contact

  validates_with SafeHtmlValidator
  validates :name, :summary, :description, presence: true

  extend FriendlyId
  friendly_id

  def display_name
    self.name
  end

  def main_contact
    original_main_contact || contacts.first
  end

  def other_contacts
    contacts - [main_contact]
  end

  def is_main_contact?(contact)
    main_contact == contact
  end

  def primary_role
    roles.where(type: PRIMARY_ROLES.collect(&:name)).first
  end

  def secondary_role
    roles.where(type: DeputyHeadOfMissionRole.name).first
  end
end
