module Edition::Identifiable
  extend ActiveSupport::Concern

  included do
    belongs_to :document
    validates :document, presence: true
    before_validation :ensure_presence_of_document, on: :create
    before_validation :update_document_slug, on: :update
    before_validation :propagate_type_to_document
  end

  delegate :slug, :change_history, to: :document

  def linkable?
    document.published?
  end

  def ensure_presence_of_document
    self.document ||= Document.new(sluggable_string: self.sluggable_title)
  end

  def update_document_slug
    document.update_slug_if_possible(self.sluggable_title)
  end

  def propagate_type_to_document
    document.document_type = type if document
  end

  module ClassMethods
    def published_as(slug)
      document = Document.where(document_type: sti_name, slug: slug).first
      document && document.published_edition
    end
  end
end
