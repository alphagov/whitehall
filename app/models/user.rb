class User < ActiveRecord::Base
  has_many :documents, foreign_key: 'author_id'
  validates_presence_of :name
  validates :email_address, email_format: { allow_blank: true }
end