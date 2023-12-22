class EditionRole < ApplicationRecord
  belongs_to :edition
  belongs_to :role, inverse_of: :edition_roles

  validates :edition, :role, presence: true
end
