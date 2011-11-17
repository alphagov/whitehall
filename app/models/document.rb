class Document < ActiveRecord::Base

  include Document::Traits

  include Document::Identifiable
  include Document::AccessControl
  include Document::Workflow
  include Document::Organisations
  include Document::Publishing

  belongs_to :author, class_name: "User"
  has_many :editorial_remarks

  validates :title, :body, :author, presence: true

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
    self.class.new(attributes.merge(state: "draft", author: user)).tap do |draft|
      traits.each { |t| t.assign_associations_to(draft) }
      if draft.save
        traits.each { |t| t.copy_associations_to(draft) }
      end
    end
  end

  def title_with_state
    "#{title} (#{state})"
  end

  class << self
    def authored_by(user)
      where(author_id: user)
    end

    def by_type(type)
      where(Document.arel_table[:type].matches("%#{type}%"))
    end

    def related_to(document)
      where(id: document.related_documents.collect(&:id))
    end
  end
end
