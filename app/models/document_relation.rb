class DocumentRelation < ActiveRecord::Base
  belongs_to :document
  belongs_to :policy

  validates :document_id, presence: true
  validates :policy_id, presence: true
  validates :document_id, uniqueness: { scope: :policy_id }

  def readonly?
    !new_record?
  end
end
