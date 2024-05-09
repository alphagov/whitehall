class User < ApplicationRecord
  include GDS::SSO::User

  belongs_to :organisation, foreign_key: :organisation_slug, primary_key: :slug

  has_many :user_world_locations
  has_many :world_locations, through: :user_world_locations
  has_many :statistics_announcements, foreign_key: :creator_id
  has_many :republishing_events

  serialize :permissions, coder: YAML, type: Array

  validates :name, presence: true

  scope :enabled, -> { where(disabled: false) }

  module Permissions
    SIGNIN = "signin".freeze
    DEPARTMENTAL_EDITOR = "Editor".freeze
    MANAGING_EDITOR = "Managing Editor".freeze
    GDS_EDITOR = "GDS Editor".freeze
    VIP_EDITOR = "VIP Editor".freeze
    PUBLISH_SCHEDULED_EDITIONS = "Publish scheduled editions".freeze
    WORLD_WRITER = "World Writer".freeze
    WORLD_EDITOR = "World Editor".freeze
    FORCE_PUBLISH_ANYTHING = "Force publish anything".freeze
    GDS_ADMIN = "GDS Admin".freeze
    PREVIEW_DESIGN_SYSTEM = "Preview design system".freeze
    PREVIEW_NEXT_RELEASE = "Preview next release".freeze
    SIDEKIQ_ADMIN = "Sidekiq Admin".freeze
    VISUAL_EDITOR_PRIVATE_BETA = "Visual editor private beta".freeze
  end

  def role
    if gds_editor? then "GDS Editor"
    elsif departmental_editor? then "Departmental Editor"
    elsif managing_editor? then "Managing Editor"
    elsif world_editor? then "World Editor"
    elsif world_writer? then "World Writer"
    else
      "Writer"
    end
  end

  def departmental_editor?
    has_permission?(Permissions::DEPARTMENTAL_EDITOR)
  end

  def managing_editor?
    has_permission?(Permissions::MANAGING_EDITOR)
  end

  def gds_editor?
    has_permission?(Permissions::GDS_EDITOR)
  end

  def vip_editor?
    has_permission?(Permissions::VIP_EDITOR)
  end

  def world_editor?
    has_permission?(Permissions::WORLD_EDITOR)
  end

  def world_writer?
    has_permission?(Permissions::WORLD_WRITER)
  end

  def gds_admin?
    has_permission?(Permissions::GDS_ADMIN)
  end

  def scheduled_publishing_robot?
    can_publish_scheduled_editions?
  end

  def location_limited?
    world_editor? || world_writer?
  end

  def can_publish_scheduled_editions?
    has_permission?(Permissions::PUBLISH_SCHEDULED_EDITIONS)
  end

  def can_force_publish_anything?
    has_permission?(Permissions::FORCE_PUBLISH_ANYTHING)
  end

  def can_preview_design_system?
    has_permission?(Permissions::PREVIEW_DESIGN_SYSTEM)
  end

  def can_preview_next_release?
    has_permission?(Permissions::PREVIEW_NEXT_RELEASE)
  end

  def can_see_visual_editor_private_beta?
    has_permission?(Permissions::VISUAL_EDITOR_PRIVATE_BETA)
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

  def fuzzy_last_name
    name.split(/ +/, 2).last
  end

  def organisation_content_id
    return organisation.content_id if organisation

    @organisation_content_id || ""
  end

  attr_writer :organisation_content_id
end
