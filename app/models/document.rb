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

  def can_be_associated_with_topics?
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

  def allows_supporting_documents?
    false
  end

  def has_supporting_documents?
    false
  end

  def create_draft(user)
    self.class.new(attributes.merge(state: "draft", creator: user)).tap do |draft|
      traits.each { |t| t.assign_associations_to(draft) }
      if draft.save
        traits.each { |t| t.copy_associations_to(draft) }
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
    document_authors.map(&:user).map(&:name)
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
