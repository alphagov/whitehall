class DocumentRelation < ActiveRecord::Base
  belongs_to :document
  belongs_to :document_identity

  validates :document_id, presence: true
  validates :document_identity, presence: true
  validates :document_identity_id, uniqueness: { scope: :document_id }

  def readonly?
    !new_record?
  end
end
