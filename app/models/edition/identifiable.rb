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
    self.document ||= Document.new(sluggable_string: string_for_slug)
  end

  def update_document_slug
    document.update_slug_if_possible(string_for_slug)
  end

  def propagate_type_to_document
    document.document_type = self.class.document_type if document
  end

  module ClassMethods
    def document_type
      sti_name
    end

    def published_as(slug, locale = I18n.default_locale)
      document = Document.at_slug(document_type, slug)
      if document.present?
        published_edition = document.published_edition
        return published_edition if published_edition.present? && published_edition.available_in_locale?(locale)
      end
      nil
    end
  end

  private

  def string_for_slug
    non_english_edition? ? nil : title(:en)
  end
end
