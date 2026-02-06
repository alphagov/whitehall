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

    add_trait Trait
  end

  def can_be_associated_with_topical_events?
    true
  end

  def search_index
    super.merge("topical_events" => topical_events.pluck(:slug))
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
end
