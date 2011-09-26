class User < ActiveRecord::Base
  has_many :editions, foreign_key: 'author_id'
  validates_presence_of :name
end