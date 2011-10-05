class Edition < ActiveRecord::Base
  include ::Transitions
  include ActiveRecord::Transitions

  delegate :type, to: :document, prefix: :document

  belongs_to :attachment

  def attach_file=(file)
    self.attachment = build_attachment(name: file)
  end

  state_machine do
    state :draft
    state :published
    state :archived

    event :publish, success: :archive_previous_editions do
      transitions from: :draft, to: :published
    end

    event :archive do
      transitions from: :published, to: :archived
    end
  end

  class DocumentHasNoUnpublishedEditionsValidator
    def validate(record)
      if record.document && record.document.editions.draft.any?
        record.errors.add(:base, "There is already an active draft for this policy")
      end
    end
  end

  class DocumentHasNoOtherPublishedEditionsValidator
    def validate(record)
      if record.published? && record.document && record.document.editions.published.any?
        record.errors.add(:policy, "has existing published editions")
      end
    end
  end

  belongs_to :author, class_name: "User"
  belongs_to :document

  has_many :fact_check_requests
  has_many :edition_topics
  has_many :topics, through: :edition_topics

  scope :draft, where(state: "draft")
  scope :unsubmitted, where(state: "draft", submitted: false)
  scope :submitted, where(state: "draft", submitted: true)
  scope :published, where(state: "published")

  validates_presence_of :title, :body, :author, :document
  validates_with DocumentHasNoUnpublishedEditionsValidator, on: :create
  validates_with DocumentHasNoOtherPublishedEditionsValidator, on: :create

  def editable_by?(user)
    draft?
  end

  def submittable_by?(user)
    draft? && !submitted?
  end

  def publishable_by?(user)
    reason_to_prevent_publication_by(user).nil?
  end

  def publish_as!(user, lock_version = self.lock_version)
    if publishable_by?(user)
      self.lock_version = lock_version
      publish!
      true
    else
      errors.add(:base, reason_to_prevent_publication_by(user))
      false
    end
  end

  def reason_to_prevent_publication_by(user)
    if published?
      "This edition has already been published"
    elsif archived?
      "This edition has been archived"
    elsif !submitted?
      "Not ready for publication"
    elsif user == author
      "You are not the second set of eyes"
    elsif !user.departmental_editor?
      "Only departmental editors can publish policies"
    end
  end

  def build_draft(user)
    draft_attributes = {state: "draft", author: user, submitted: false}
    self.class.new(attributes.merge(draft_attributes))
  end

  def archive_previous_editions
    document.editions.published.each do |edition|
      edition.archive! unless edition == self
    end
  end
end
