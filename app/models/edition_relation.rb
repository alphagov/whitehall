class EditionRelation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :doc_identity

  validates :edition_id, presence: true
  validates :doc_identity, presence: true
  validates :doc_identity_id, uniqueness: { scope: :edition_id }

  def readonly?
    !new_record?
  end
end
