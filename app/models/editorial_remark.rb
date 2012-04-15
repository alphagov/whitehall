class EditorialRemark < ActiveRecord::Base
  belongs_to :document, foreign_key: :edition_id
  belongs_to :author, class_name: "User"

  validates :document, :body, :author, presence: true
end