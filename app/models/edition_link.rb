class EditionLink < ApplicationRecord
  belongs_to :edition
  belongs_to :document
  scope :of_type, ->(type) { where(link_type: type) }
  validate :is_not_self

  def is_not_self
    return unless edition.document == document

    errors.add(:base, "cannot include an association with this document (\"#{edition.title}\")")
  end
end
