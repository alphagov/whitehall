module Edition::TopicalEvents
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.topical_event_featurings = @edition.topical_event_featurings.map do |cf|
        TopicalEventFeaturing.new(cf.attributes.except("id"))
      end

      edition.topical_event_memberships = @edition.topical_event_memberships.map do |dt|
        TopicalEventMembership.new(dt.attributes.except("id"))
      end

      edition.topical_event_links = @edition.topical_event_links.map do |link|
        EditionLink.new(link.attributes.except("id"))
      end
    end
  end

  included do
    has_many :topical_event_featurings, dependent: :destroy, foreign_key: :edition_id
    has_many :topical_event_memberships, dependent: :destroy, inverse_of: :edition, foreign_key: :edition_id
    has_many :topical_events, through: :topical_event_memberships, source: :topical_event
    has_many :topical_event_links, -> { of_type "topical_event" }, class_name: "EditionLink", dependent: :destroy, inverse_of: :edition, foreign_key: :edition_id
    has_many :topical_event_documents, through: :topical_event_links, source: :document

    validate :cannot_remove_topical_event_association_if_currently_featured

    add_trait Trait
  end

  def can_be_associated_with_topical_events?
    true
  end

  def search_index
    super.merge("topical_events" => topical_events.pluck(:slug))
  end

  # Your form posts edition[topical_event_document_ids][]
  # Capture removals here because *_ids assignment doesn't mark join rows for destruction.
  def topical_event_document_ids=(ids)
    ids = Array(ids).reject(&:blank?).map(&:to_i)

    if persisted?
      current_ids = EditionLink.of_type("topical_event").where(edition_id: id).pluck(:document_id)
      @removed_topical_event_document_ids = current_ids - ids
    else
      @removed_topical_event_document_ids = []
    end

    super
  end

  # WARNING:
  # The existing associations above (topical_event_links / topical_event_documents) are OUTBOUND:
  #   "this edition belongs to these topical event documents"
  #
  # The methods below are INBOUND and only make sense when this edition *is* the topical event.
  # They deliberately raise for non-topical-event editions to avoid accidental misuse.

  def topical_event_member_links
    raise_if_doc_not_a_topical_event!

    EditionLink.of_type("topical_event").where(document_id: document_id)
  end

  def topical_event_member_editions
    raise_if_doc_not_a_topical_event!

    Edition.where(id: topical_event_member_links.select(:edition_id))
  end

  def topical_event_member_documents
    raise_if_doc_not_a_topical_event!

    Document.where(id: topical_event_member_editions.select(:document_id))
  end

private

  def raise_if_doc_not_a_topical_event!
    return if respond_to?(:configurable_document_type) && configurable_document_type == "topical_event"

    raise ArgumentError,
          "Inbound topical-event lookups only valid for StandardEdition configurable_document_type='topical_event' (got #{respond_to?(:configurable_document_type) ? configurable_document_type.inspect : 'n/a'})"
  end

  def cannot_remove_topical_event_association_if_currently_featured
    removed_ids = @removed_topical_event_document_ids
    return if removed_ids.blank?

    removed_ids.each do |topical_event_document_id|
      topical_event_edition = Document.find(topical_event_document_id).latest_edition
      next if topical_event_edition.nil?

      # Only block if this edition's *document* is currently featured on that topical event edition
      if currently_featured_on?(topical_event_edition)
        errors.add(
          :topical_event_document_ids,
          "can’t remove this topical event while this edition’s document is currently featured on it (remove the feature first)"
        )
      end
    end
  end

  def currently_featured_on?(topical_event_edition)
    return false unless topical_event_edition.respond_to?(:feature_lists)

    # A Feature stores the featured item's document_id.
    Feature.joins(:feature_list)
           .where(feature_lists: { featurable_type: "Edition", featurable_id: topical_event_edition.id })
           .where(document_id: document_id)
           .where(ended_at: nil)
           .exists?
  end
end
