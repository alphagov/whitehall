class User < ActiveRecord::Base
  include GDS::SSO::User

  belongs_to :organisation

  serialize :permissions, Hash

  validates :name, presence: true
  validates :email, email_format: { allow_blank: true }

  module Permissions
    SIGNIN = 'signin'
    DEPARTMENTAL_EDITOR = 'Editor'
    PUBLISH_SCHEDULED_EDITIONS = 'Publish scheduled editions'
  end

  def role
    departmental_editor? ? "Departmental Editor" : "Policy Writer"
  end

  def departmental_editor?
    has_permission?(GDS::SSO::Config.default_scope, Permissions::DEPARTMENTAL_EDITOR)
  end

  def can_publish_scheduled_editions?
    has_permission?(GDS::SSO::Config.default_scope, Permissions::PUBLISH_SCHEDULED_EDITIONS)
  end

  def organisation_name
    organisation ? organisation.name : nil
  end

  def has_email?
    email.present?
  end
end