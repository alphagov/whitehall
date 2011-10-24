class Topic < ActiveRecord::Base
  has_many :document_topics
  has_many :documents, through: :document_topics
  has_many :published_documents, through: :document_topics, class_name: "Document", conditions: { state: "published" }, source: :document

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    new_record?
  end

  def self.with_published_documents
    joins(:published_documents).group(:topic_id)
  end
end