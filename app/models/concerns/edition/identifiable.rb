module Edition::Identifiable
  extend ActiveSupport::Concern

  included do
    belongs_to :document, touch: true
    validates :document, presence: true
    before_validation :ensure_presence_of_document, on: :create
    before_validation :update_document_slug, on: :update
    before_validation :propagate_type_to_document

    scope :latest_edition, -> { joins(:document).where("editions.id = documents.latest_edition_id") }
    scope :live_edition, -> { joins(:document).where("documents.live_edition_id = editions.id") }

    scope :review_overdue,
          lambda {
            joins(document: :review_reminder)
              .where(document: { review_reminders: { review_at: ..Time.zone.today } })
              .where.not(first_published_at: nil)
          }
  end

  delegate :slug, :change_history, :content_id, to: :document, allow_nil: true

  def linkable?
    document.live? || document.published_very_soon?
  end

  def ensure_presence_of_document
    if document.blank?
      self.document = Document.new(
        sluggable_string: string_for_slug,
        content_id: SecureRandom.uuid,
      )
    elsif document.new_record?
      document.sluggable_string = string_for_slug if document.slug.blank?
      document.content_id = SecureRandom.uuid if document.content_id.blank?
    end
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
        live_edition = document.live_edition
        return live_edition if live_edition.present? && live_edition.available_in_locale?(locale)
      end
      nil
    end
  end

private

  def string_for_slug
    non_english_edition? ? nil : title(:en)
  end
end
