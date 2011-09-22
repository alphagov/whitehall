class Policy < ActiveRecord::Base
  belongs_to :author, class_name: "User"

  scope :drafts, where(submitted: false)
  scope :submitted, where(submitted: true, published: false)
  scope :published, where(published: true)

  validates_presence_of :title, :body, :author

  def publish_as!(user)
    if user != author
      update_attribute(:published, true)
      true
    else
      false
    end
  end
end
