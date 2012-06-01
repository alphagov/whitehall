class User < ActiveRecord::Base
  include GDS::SSO::User

  belongs_to :organisation

  validates :name, presence: true
  validates :email, email_format: { allow_blank: true }

  def role
    departmental_editor? ? "Departmental Editor" : "Policy Writer"
  end

  def organisation_name
    organisation ? organisation.name : nil
  end

  def has_email?
    email.present?
  end
end