class EditionRelation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :document

  validates :edition_id, presence: true
  validates :document, presence: true
  validates :document_id, uniqueness: { scope: :edition_id }

  def readonly?
    !new_record?
  end
end
