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
end
