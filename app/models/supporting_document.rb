class SupportingDocument < ActiveRecord::Base
  belongs_to :document

  validates :title, :body, :document, presence: true
end