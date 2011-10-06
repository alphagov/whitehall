class Topic < ActiveRecord::Base
  has_many :edition_topics
  has_many :editions, through: :edition_topics

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end