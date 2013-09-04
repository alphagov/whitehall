# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  email               :string(255)
#  organisation_id     :integer
#  uid                 :string(255)
#  version             :integer
#  permissions         :text
#  remotely_signed_out :boolean          default(FALSE)
#

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
    WORLD_WRITER = 'World Writer'
    WORLD_EDITOR = 'World Editor'
    FORCE_PUBLISH_ANYTHING = 'Force publish anything'
  end

  def role
    case
    when gds_editor? then "GDS Editor"
    when departmental_editor? then "Departmental Editor"
    when world_editor? then 'World Editor'
    when world_writer? then 'World Writer'
    else "Policy Writer"
    end
  end

  def departmental_editor?
    has_permission?(Permissions::DEPARTMENTAL_EDITOR)
  end

  def gds_editor?
    has_permission?(Permissions::GDS_EDITOR)
  end

  def world_editor?
    has_permission?(Permissions::WORLD_EDITOR)
  end

  def world_writer?
    has_permission?(Permissions::WORLD_WRITER)
  end

  def location_limited?
    world_editor? || world_writer?
  end

  def can_publish_scheduled_editions?
    has_permission?(Permissions::PUBLISH_SCHEDULED_EDITIONS)
  end

  def can_import?
    has_permission?(Permissions::IMPORT)
  end

  def can_force_publish_anything?
    has_permission?(Permissions::FORCE_PUBLISH_ANYTHING)
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
