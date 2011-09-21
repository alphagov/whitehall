class Policy < ActiveRecord::Base
  belongs_to :author, :class_name => "User"

  validates_presence_of :title
  validates_presence_of :body
end
