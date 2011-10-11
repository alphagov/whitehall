class Document < ActiveRecord::Base
  include ::Transitions
  include ActiveRecord::Transitions

  belongs_to :attachment

  belongs_to :author, class_name: "User"
  belongs_to :document_identity

  has_many :fact_check_requests

  has_many :document_topics
  has_many :topics, through: :document_topics

  has_many :document_organisations
  has_many :organisations, through: :document_organisations

  has_many :document_roles
  has_many :roles, through: :document_roles

  scope :draft, where(state: "draft")
  scope :unsubmitted, where(state: "draft", submitted: false)
  scope :submitted, where(state: "draft", submitted: true)
  scope :published, where(state: "published")

  state_machine do
    state :draft
    state :published
    state :archived

    event :publish, success: :archive_previous_documents do
      transitions from: :draft, to: :published
    end

    event :archive do
      transitions from: :published, to: :archived
    end
  end

  class DocumentHasNoUnpublishedDocumentsValidator
    def validate(record)
      if record.document_identity && record.document_identity.documents.draft.any?
        record.errors.add(:base, "There is already an active draft for this document")
      end
    end
  end

  class DocumentHasNoOtherPublishedDocumentsValidator
    def validate(record)
      if record.published? && record.document_identity && record.document_identity.documents.published.any?
        record.errors.add(:policy, "has existing published editions")
      end
    end
  end

  validates_presence_of :title, :body, :author, :document_identity
  validates_with DocumentHasNoUnpublishedDocumentsValidator, on: :create
  validates_with DocumentHasNoOtherPublishedDocumentsValidator, on: :create

  class << self
    def from_public_identity(id)
      identity = DocumentIdentity.find_by_id(id)
      identity.published_document
    end
  end

  def attach_file=(file)
    self.attachment = build_attachment(name: file)
  end

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
    draft_attributes = {state: "draft", author: user, submitted: false, topics: topics}
    self.class.new(attributes.merge(draft_attributes))
  end

  def archive_previous_documents
    document_identity.documents.published.each do |document|
      document.archive! unless document == self
    end
  end
end
