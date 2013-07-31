class DocumentSource < ActiveRecord::Base
  belongs_to :document
  belongs_to :import

  validates :url, presence: true, uniqueness: true, uri: true
end
