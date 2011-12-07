class DocumentRelation < ActiveRecord::Base
  belongs_to :document
  belongs_to :related_document, class_name: "Document"

  validates :document_id, presence: true
  validates :related_document_id, presence: true
  validates :document_id, uniqueness: { scope: :related_document_id }

  after_create :create_inverse_relation
  after_destroy :destroy_inverse_relation

  class << self
    def relation_for(document_id, related_document_id)
      where(document_id: document_id, related_document_id: related_document_id).first
    end
  end

  def inverse_relation
    self.class.relation_for(related_document_id, document_id)
  end

  def readonly?
    !new_record?
  end

  def create_inverse_relation
    unless inverse_relation.present?
      self.class.create!(
        document_id: related_document_id,
        related_document_id: document_id
      )
    end
  end

  def destroy_inverse_relation
    if inverse_relation.present?
      inverse_relation.destroy
    end
  end
end
