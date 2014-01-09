module Edition::Classifications
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.classification_memberships = @edition.classification_memberships.map do |dt|
        ClassificationMembership.new(dt.attributes.except('id'))
      end
    end
  end

  included do
    has_many :classification_memberships, dependent: :destroy, foreign_key: :edition_id

    add_trait Trait
  end
end
