# TODO: we want to make the concept of linking documents to other documents more 'abstract'
# i.e. drop the 'topical event' specific language throughout Whitehall.
module Edition::TopicalEvents
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.topical_event_links = @edition.topical_event_links.map do |link|
        EditionLink.new(link.attributes.except("id"))
      end
    end
  end

  included do
    has_many :topical_event_links, -> { of_type "topical_event" }, class_name: "EditionLink", dependent: :destroy, inverse_of: :edition, foreign_key: :edition_id
    has_many :topical_event_documents, through: :topical_event_links, source: :document

    add_trait Trait
  end

  # This method can be deleted when all legacy content types have been migrated to
  # being config-driven (which has its own implementation of the method).
  def can_be_associated_with_topical_events?
    true
  end
end
