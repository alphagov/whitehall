class EditionRelation < ApplicationRecord
  belongs_to :edition
  belongs_to :document, inverse_of: :edition_relations

  validates :edition, presence: true
  validates :document, presence: true
  validates :document_id, uniqueness: { scope: :edition_id }
end
