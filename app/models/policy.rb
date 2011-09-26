class Policy < ActiveRecord::Base
  belongs_to :author, class_name: "User"

  scope :drafts, where(submitted: false)
  scope :submitted, where(submitted: true, published: false)
  scope :published, where(published: true)

  validates_presence_of :title, :body, :author

  def publish_as!(user, lock_version = self.lock_version)
    if user == author
      errors.add(:base, "You are not the second set of eyes")
    elsif !user.departmental_editor?
      errors.add(:base, "Only departmental editors can publish policies")
    else
      update_attributes(published: true, lock_version: lock_version)
    end
    errors.empty?
  rescue ActiveRecord::StaleObjectError
    errors.add(:base, "This policy has been edited since you viewed it")
    false
  end
end
