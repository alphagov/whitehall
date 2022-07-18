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
    end
  end

  included do
    has_many :topical_event_featurings, dependent: :destroy, foreign_key: :edition_id
    has_many :topical_event_memberships, dependent: :destroy, inverse_of: :edition, foreign_key: :edition_id
    has_many :topical_events, through: :topical_event_memberships, source: :topical_event

    add_trait Trait
  end

  def can_be_associated_with_topical_events?
    true
  end

  def search_index
    super.merge("topical_events" => topical_events.pluck(:slug))
  end
end
