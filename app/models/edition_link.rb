class EditionLink < ApplicationRecord
  belongs_to :edition
  belongs_to :document
  scope :of_type, ->(type) { where(link_type: type) }
end
