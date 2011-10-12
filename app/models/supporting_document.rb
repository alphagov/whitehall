class SupportingDocument < ActiveRecord::Base
  belongs_to :document

  validates :title, :body, presence: true
end