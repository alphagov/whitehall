class Document < ActiveRecord::Base
  include ::Transitions
  include ActiveRecord::Transitions

  belongs_to :author, class_name: "User"
  belongs_to :document_identity

  has_many :fact_check_requests

  has_many :document_topics
  has_many :topics, through: :document_topics

  has_many :document_organisations
  has_many :organisations, through: :document_organisations

  has_many :document_ministerial_roles
  has_many :ministerial_roles, through: :document_ministerial_roles

  has_many :document_relations_to, class_name: "DocumentRelation", foreign_key: 'document_id'
  has_many :document_relations_from, class_name: "DocumentRelation", foreign_key: 'related_document_id'

  has_many :documents_related_with, through: :document_relations_to, source: :related_document
  has_many :documents_related_to, through: :document_relations_from, source: :document

  def related_documents
    [*documents_related_to, *documents_related_with].uniq
  end

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
        record.errors.add(:base, "There is already a published edition for this document")
      end
    end
  end

  validates_presence_of :title, :body, :author, :document_identity
  validates_with DocumentHasNoUnpublishedDocumentsValidator, on: :create
  validates_with DocumentHasNoOtherPublishedDocumentsValidator, on: :create

  class << self
    def published_as(id)
      identity = DocumentIdentity.from_param(id)
      identity && identity.published_document
    end

    def in_topic(topic)
      joins(:topics).where('topics.id' => topic)
    end

    def in_organisation(organisation)
      joins(:organisations).where('organisations.id' => organisation)
    end

    def in_ministerial_role(role)
      joins(:ministerial_roles).where('roles.id' => role)
    end
  end

  def initialize(*args, &block)
    super
    self.document_identity ||= DocumentIdentity.new
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

  def submit_as(user)
    update_attribute(:submitted, true)
  end

  def publishable_by?(user)
    reason_to_prevent_publication_by(user).nil?
  end

  def publish_as(user, lock_version = self.lock_version)
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
      "Only departmental editors can publish"
    end
  end

  def create_draft(user)
    draft_attributes = {
      state: "draft", author: user, submitted: false, topics: topics,
      organisations: organisations, ministerial_roles: ministerial_roles,
      documents_related_with: documents_related_with, documents_related_to: documents_related_to
    }
    new_draft = self.class.create(attributes.merge(draft_attributes))
    if new_draft.valid? && allows_supporting_documents?
      supporting_documents.each do |sd|
        new_draft.supporting_documents.create(sd.attributes.except("document_id"))
      end
    end
    new_draft
  end

  def archive_previous_documents
    document_identity.documents.published.each do |document|
      document.archive! unless document == self
    end
  end

  def allows_attachment?
    respond_to?(:attachment)
  end

  def allows_supporting_documents?
    respond_to?(:supporting_documents)
  end

  def title_with_state
    state_string = (draft? && submitted?) ? 'submitted' : state
    "#{title} (#{state_string})"
  end
end
