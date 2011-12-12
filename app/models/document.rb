class Document < ActiveRecord::Base
  include Document::Traits

  include Document::Identifiable
  include Document::AccessControl
  include Document::Workflow
  include Document::Organisations
  include Document::Publishing

  has_many :editorial_remarks
  has_many :document_authors

  validates :title, :body, :creator, presence: true

  class UnmodifiableOncePublishedValidator < ActiveModel::Validator
    def validate(record)
      if record.unmodifiable?
        record.significant_changed_attributes.each do |attribute|
          record.errors.add(attribute, "cannot be modified when document is in the #{record.state} state")
        end
      end
    end
  end

  validates_with UnmodifiableOncePublishedValidator

  UNMODIFIABLE_STATES = %w(published archived deleted).freeze

  def unmodifiable?
    persisted? && UNMODIFIABLE_STATES.include?(state_was)
  end

  def significant_changed_attributes
    changed - %w(state updated_at)
  end

  def creator
    document_authors.first && document_authors.first.user
  end

  def creator=(user)
    if new_record?
      document_author = document_authors.first || document_authors.build
      document_author.user = user
    else
      raise "author can only be set on new records"
    end
  end

  def can_be_associated_with_policy_areas?
    false
  end

  def can_be_associated_with_ministers?
    false
  end

  def can_be_associated_with_countries?
    false
  end

  def can_be_fact_checked?
    false
  end

  def can_be_related_to_other_documents?
    false
  end

  def can_apply_to_subset_of_nations?
    false
  end

  def allows_attachments?
    false
  end

  def allows_supporting_pages?
    false
  end

  def has_supporting_pages?
    false
  end

  def create_draft(user)
    self.class.new(attributes.merge(state: "draft", creator: user)).tap do |draft|
      traits.each { |t| t.process_associations_before_save(draft) }
      if draft.save
        traits.each { |t| t.process_associations_after_save(draft) }
      end
    end
  end

  def save_as(user)
    if save
      document_authors.create!(user: user)
    end
  end

  def edit_as(user, attributes = {})
    assign_attributes(attributes)
    save_as(user)
  end

  def author_names
    document_authors.map(&:user).map(&:name).uniq
  end

  def title_with_state
    "#{title} (#{state})"
  end

  class << self
    def authored_by(user)
      joins(:document_authors).where(document_authors: {user_id: user}).group(:document_id)
    end

    def by_type(type)
      where(Document.arel_table[:type].matches("%#{type}%"))
    end

    def related_to(document)
      where(id: document.related_documents.collect(&:id))
    end
  end
end
