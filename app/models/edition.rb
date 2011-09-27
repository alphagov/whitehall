class Edition < ActiveRecord::Base
  class PolicyHasNoUnpublishedEditionsValidator
    def validate(record)
      if record.policy && record.policy.editions.unpublished.any?
        record.errors.add(:policy, "has existing unpublished editions")
      end
    end
  end

  belongs_to :author, class_name: "User"
  belongs_to :policy

  scope :drafts, where(submitted: false)
  scope :submitted, where(submitted: true, published: false)
  scope :published, where(published: true)
  scope :unpublished, where(published: false)

  validates_presence_of :title, :body, :author, :policy
  validates_with PolicyHasNoUnpublishedEditionsValidator, on: :create

  def publish_as!(user, lock_version = self.lock_version)
    if user == author
      errors.add(:base, "You are not the second set of eyes")
    elsif !user.departmental_editor?
      errors.add(:base, "Only departmental editors can publish policies")
    else
      update_attributes(published: true, lock_version: lock_version)
    end
    errors.empty?
  end

  def build_draft(user)
    draft_attributes = {published: false, submitted: false, author: user}
    self.class.new(attributes.merge(draft_attributes))
  end
end
