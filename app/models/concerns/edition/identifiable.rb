module Edition::Identifiable
  extend ActiveSupport::Concern

  included do
    belongs_to :document, touch: true
    validates :document, presence: true
    before_validation :ensure_presence_of_document, on: :create
    before_validation :update_document_slug, on: :update
    before_validation :propagate_type_to_document
    before_save :set_slug, if: :title_changed?

    scope :latest_edition, -> { joins(:document).where("editions.id = documents.latest_edition_id") }
    scope :live_edition, -> { joins(:document).where("documents.live_edition_id = editions.id") }

    scope :review_overdue,
          lambda {
            joins(document: :review_reminder)
              .where(document: { review_reminders: { review_at: ..Time.zone.today } })
              .where.not(first_published_at: nil)
          }
  end

  delegate :change_history, :content_id, to: :document, allow_nil: true

  def slug
    Flipflop.slugs_for_editions? ? super : document.slug
  end

  def set_slug
    # Translations return nil from `string_to_slug`, in which case we return early as we should not set the slug based on a translation title
    return if string_for_slug.nil?

    # Generate a default slug using the babosa gem's to_slug and normalize methods
    # We truncate the slug to 150 bytes to keep base_path values to less than 256 bytes,
    # as longer base paths aren't supported downstream.
    default_slug = string_for_slug.to_slug.normalize(to_ascii: true, max_length: 150).to_s

    # For languages the babosa gem does not support, its `normalize` method will return an empty string
    # when the to_ascii option is used. In this case we fall back to the document ID as the slug
    if default_slug.blank?
      self[:slug] = document_id
      return
    end

    candidate_slug_is_a_duplicate = true
    attempt = 1
    while candidate_slug_is_a_duplicate
      candidate_slug = default_slug
      if attempt > 1
        candidate_slug += "--#{attempt}"
      end

      edition_with_conflicting_slug = Edition.where_base_path_prefix_matches(self)
                                             .where(slug: candidate_slug)
                                             .where("document_id != ?", document_id)

      if edition_with_conflicting_slug.exists?
        attempt += 1
      else
        candidate_slug_is_a_duplicate = false
        self[:slug] = candidate_slug
      end
    end
  end

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

    def where_base_path_prefix_matches(edition)
      scope = Edition.where(type: edition.type)
      if edition.configurable_document_type.present?
        configurable_types = ConfigurableDocumentType.find_by_base_path_prefix(edition.type_instance.settings["base_path_prefix"])
        scope = scope.where(configurable_document_type: configurable_types.map(&:key))
      end
      scope
    end
  end

private

  def string_for_slug
    non_english_edition? ? nil : title(:en)
  end
end
