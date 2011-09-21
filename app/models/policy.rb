class Policy < ActiveRecord::Base
  belongs_to :author, :class_name => "User"

  scope :drafts, where(:submitted => false)
  scope :submitted, where(:submitted => true)

  validates_presence_of :title
  validates_presence_of :body
end
