class EditorialRemark < ActiveRecord::Base
  belongs_to :document
  belongs_to :author, class_name: "User"
  
  validates :document, :body, :author, presence: true
end