module Edition::WorldwideOrganisations
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.edition_worldwide_organisations.each do |association|
        edition.edition_worldwide_organisations.build(association.attributes.except("id"))
      end
    end
  end

  included do
    has_many :edition_worldwide_organisations, foreign_key: :edition_id, inverse_of: :edition, dependent: :destroy
    has_many :legacy_worldwide_organisations, through: :edition_worldwide_organisations

    validate :at_least_one_worldwide_organisations

    add_trait Trait
  end

  def can_be_associated_with_worldwide_organisations?
    true
  end

  def skip_worldwide_organisations_validation?
    true
  end

  def at_least_one_worldwide_organisations
    if !skip_worldwide_organisations_validation? && legacy_worldwide_organisations.empty?
      errors.add(:legacy_worldwide_organisations, "at least one required")
    end
  end
end
