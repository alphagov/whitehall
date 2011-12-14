class FactCheckRequest < ActiveRecord::Base
  include Whitehall::RandomKey
  self.random_key_length = 16

  belongs_to :document
  belongs_to :requestor, class_name: "User"

  validates :document, :email_address, :requestor, presence: true
  validates :email_address, email_format: {allow_blank: true}

  scope :completed, where('comments IS NOT NULL')
  scope :pending, where('comments IS NULL')

  def requestor_contactable?
    requestor.email.present?
  end
end