class DocumentSource < ActiveRecord::Base
  belongs_to :document
  belongs_to :import

  validates :url, presence: true, uniqueness: true, format: URI::regexp(%w(http https))
end