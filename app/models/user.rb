class User < ActiveRecord::Base
  belongs_to :organisation
  has_many :documents, foreign_key: 'author_id'

  validates :name, presence: true
  validates :email_address, email_format: { allow_blank: true }

  def role
    departmental_editor? ? "Departmental Editor" : "Policy Writer"
  end

  def organisation_name
    organisation ? organisation.name : nil
  end
end