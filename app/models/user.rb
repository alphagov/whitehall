class User < ActiveRecord::Base
  include GDS::SSO::User

  belongs_to :organisation

  serialize :permissions, Hash

  validates :name, presence: true
  validates :email, email_format: { allow_blank: true }

  def role
    departmental_editor? ? "Departmental Editor" : "Policy Writer"
  end

  def departmental_editor?
    has_permission?(GDS::SSO::Config.default_scope, 'Editor')
  end

  def organisation_name
    organisation ? organisation.name : nil
  end

  def has_email?
    email.present?
  end
end