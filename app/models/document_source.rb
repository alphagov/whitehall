class DocumentSource < ActiveRecord::Base
  belongs_to :document

  validates :url, presence: true, uniqueness: true, uri: true
end
