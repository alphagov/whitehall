class Topic < ActiveRecord::Base
  has_many :edition_topics
  has_many :editions, through: :edition_topics
  has_many :published_editions, through: :edition_topics, class_name: "Edition", conditions: { state: "published" }, source: :edition
  has_many :published_policies, through: :edition_topics, class_name: "Policy", conditions: { state: "published" }, source: :edition
  has_many :published_publications, through: :edition_topics, class_name: "Publication", conditions: { state: "published" }, source: :edition

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  def self.with_published_documents
    joins(:published_editions)
  end
end