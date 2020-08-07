class DocumentSource < ApplicationRecord
  belongs_to :document

  validates :url, presence: true, uri: true, uniqueness: { case_sensitive: false }
end
