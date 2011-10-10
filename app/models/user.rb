class User < ActiveRecord::Base
  has_many :documents, foreign_key: 'author_id'
  validates_presence_of :name
end