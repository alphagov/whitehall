class FactCheckRequest < ApplicationRecord
  include Whitehall::RandomKey
  self.random_key_length = 16

  belongs_to :edition
  belongs_to :requestor, class_name: "User"

  validates :edition, :email_address, :requestor, presence: true
  validates :email_address, email_format: { allow_blank: true }

  scope :completed, -> { where("comments IS NOT NULL") }
  scope :pending,   -> { where("comments IS NULL") }

  def self.for_editions(editions)
    FactCheckRequest.where(edition_id: editions)
  end

  def requestor_contactable?
    requestor.email.present?
  end

  delegate :title, to: :edition, prefix: true

  def edition_type
    edition.format_name
  end
end
