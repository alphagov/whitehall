class Topic < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :document_topics
  has_many :documents, through: :document_topics
end