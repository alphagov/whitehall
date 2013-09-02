# == Schema Information
#
# Table name: edition_relations
#
#  id          :integer          not null, primary key
#  edition_id  :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#  document_id :integer
#

class EditionRelation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :document

  validates :edition_id, presence: true
  validates :document, presence: true
  validates :document_id, uniqueness: { scope: :edition_id }

  after_create :update_published_related_edition_counts
  after_destroy :update_published_related_edition_counts

  def readonly?
    !new_record?
  end

  private

  def update_published_related_edition_counts
    if document.published_edition.present? && document.published_edition.respond_to?(:update_published_related_publication_count)
      document.published_edition.update_published_related_publication_count
    end
  end
end
