class Topic < ActiveRecord::Base
  has_many :edition_topics
  has_many :editions, through: :edition_topics

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  def published_policies
    published_documents.select { |document| document.is_a?(Policy) }
  end

  def published_publications
    published_documents.select { |document| document.is_a?(Publication) }
  end

  def published_documents
    editions.published.includes(:document).map(&:document)
  end

  def self.with_published_documents
    all.select { |topic| topic.published_documents.any? }
  end
end