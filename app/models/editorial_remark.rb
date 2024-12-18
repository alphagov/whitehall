class EditorialRemark < ApplicationRecord
  belongs_to :edition
  belongs_to :author, class_name: "User"

  validates :edition, :body, :author, presence: true

  def is_for_newer_edition?(edition)
    edition_id > edition.id
  end

  def is_for_current_edition?(edition)
    edition_id == edition.id
  end

  def is_for_older_edition?(edition)
    edition_id < edition.id
  end
end
