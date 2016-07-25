module Edition::TopicalEvents
  extend ActiveSupport::Concern
  include Edition::Classifications

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.classification_featurings = @edition.classification_featurings.map do |cf|
        ClassificationFeaturing.new(cf.attributes.except('id'))
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

  def search_index
    # "Policy area" is the newer name for "topic"
    # (https://www.gov.uk/government/topics)
    # Rummager's policy areas also include "topical events", which we model
    # separately in whitehall.
    new_slugs = topical_events.map(&:slug)
    existing_slugs = super.fetch("policy_areas", [])
    super.merge("policy_areas" => new_slugs + existing_slugs)
  end
end
