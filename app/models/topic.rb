class Topic < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :edition_topics
  has_many :editions, through: :edition_topics
  has_many :documents, through: :editions
end