class Topic < ActiveRecord::Base
  has_many :document_topics
  has_many :documents, through: :document_topics
  has_many :published_documents, through: :document_topics, class_name: "Document", conditions: { state: "published" }, source: :document
  has_many :published_policies, through: :document_topics, class_name: "Policy", conditions: { state: "published" }, source: :document
  has_many :published_publications, through: :document_topics, class_name: "Publication", conditions: { state: "published" }, source: :document

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  def self.with_published_documents
    joins(:published_documents).group(:topic_id)
  end
end