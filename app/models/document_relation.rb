class DocumentRelation < ActiveRecord::Base
  belongs_to :document, foreign_key: :edition_id
  belongs_to :doc_identity

  validates :edition_id, presence: true
  validates :doc_identity, presence: true
  validates :doc_identity_id, uniqueness: { scope: :edition_id }

  def readonly?
    !new_record?
  end
end
