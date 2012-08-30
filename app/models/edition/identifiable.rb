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

  def previewable?
    !document.published_edition.is_latest_edition?
  end

  def ensure_presence_of_document
    self.document ||= Document.new(sluggable_string: self.sluggable_title)
  end

  def update_document_slug
    document.update_slug_if_possible(self.sluggable_title)
  end

  def propagate_type_to_document
    document.document_type = self.class.document_type if document
  end

  module ClassMethods
    def document_type
      sti_name
    end

    def published_as(slug)
      document = Document.at_slug(document_type, slug)
      document && document.published_edition
    end
  end
end
