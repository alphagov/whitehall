module Edition::TopicalEvents
  extend ActiveSupport::Concern
  include Edition::Classifications

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.classification_featurings = @edition.classification_featurings.map do |cf|
        ClassificationFeaturing.new(cf.attributes.except(:id))
      end
    end
  end

  included do
    has_many :topical_events, through: :classification_memberships, source: :topical_event
    has_many :classification_featurings, dependent: :destroy, foreign_key: :edition_id

    add_trait Trait
  end

  def can_be_associated_with_topical_events?
    true
  end

  module InstanceMethods
    def search_index
      super.merge("topical_events" => topical_events.map(&:slug))
    end
  end

  module ClassMethods
    def in_topical_event(topical_event)
      joins(:topical_events).where('classifications.id' => topical_event)
    end

    def published_in_topical_event(topical_event)
      published.in_topical_event(topical_event)
    end

    def scheduled_in_topical_event(topical_event)
      scheduled.in_topical_event(topical_event)
    end
  end
end
