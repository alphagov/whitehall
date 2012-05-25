class EditorialRemark < ActiveRecord::Base
  belongs_to :edition
  belongs_to :author, class_name: "User"

  validates :edition, :body, :author, presence: true
end