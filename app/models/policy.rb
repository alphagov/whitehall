class Policy < ActiveRecord::Base
  belongs_to :author, :class_name => "User"

  scope :drafts, where(:submitted => false)
  scope :submitted, where(:submitted => true)
  scope :published, where(:published => true)

  validates_presence_of :title, :body, :author

  def publish!
    update_attribute(:published, true)
  end
end
