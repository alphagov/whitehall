class FactCheckRequest < ActiveRecord::Base
  include Whitehall::RandomKey
  self.random_key_length = 16

  belongs_to :document
  validates_presence_of :document, :email_address
  validates :email_address, email_format: {allow_blank: true}

  scope :completed, where('comments IS NOT NULL')
  scope :pending, where('comments IS NULL')
end