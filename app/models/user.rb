class User < ActiveRecord::Base
  include GDS::SSO::User

  belongs_to :organisation

  has_many :user_world_locations
  has_many :world_locations, through: :user_world_locations

  serialize :permissions, Array
  attr_protected :permissions

  validates :name, presence: true
  validates :email, email_format: { allow_blank: true }

  module Permissions
    SIGNIN = 'signin'
    DEPARTMENTAL_EDITOR = 'Editor'
    GDS_EDITOR = 'GDS Editor'
    PUBLISH_SCHEDULED_EDITIONS = 'Publish scheduled editions'
    IMPORT = 'Import CSVs'
  end

  def role
    return "GDS Editor" if gds_editor?
    return "Departmental Editor" if departmental_editor?
    "Policy Writer"
  end

  def departmental_editor?
    has_permission?(Permissions::DEPARTMENTAL_EDITOR)
  end

  def gds_editor?
    has_permission?(Permissions::GDS_EDITOR)
  end

  def can_publish_scheduled_editions?
    has_permission?(Permissions::PUBLISH_SCHEDULED_EDITIONS)
  end

  def can_import?
    has_permission?(Permissions::IMPORT)
  end

  def organisation_name
    organisation ? organisation.name : nil
  end

  def has_email?
    email.present?
  end

  def editable_by?(user)
    user.gds_editor?
  end

  def can_handle_fatalities?
    gds_editor? || (organisation && organisation.handles_fatalities?)
  end
end
