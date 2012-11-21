class User < ActiveRecord::Base
  include GDS::SSO::User

  belongs_to :organisation

  serialize :permissions, Hash
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
    has_permission?(GDS::SSO::Config.default_scope, Permissions::DEPARTMENTAL_EDITOR)
  end

  def gds_editor?
    has_permission?(GDS::SSO::Config.default_scope, Permissions::GDS_EDITOR)
  end

  def can_publish_scheduled_editions?
    has_permission?(GDS::SSO::Config.default_scope, Permissions::PUBLISH_SCHEDULED_EDITIONS)
  end

  def can_import?
    has_permission?(GDS::SSO::Config.default_scope, Permissions::IMPORT)
  end

  def organisation_name
    organisation ? organisation.name : nil
  end

  def has_email?
    email.present?
  end
end