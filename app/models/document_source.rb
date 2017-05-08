class DocumentSource < ApplicationRecord
  belongs_to :document

  validates :url, presence: true, uniqueness: true, uri: true
end
