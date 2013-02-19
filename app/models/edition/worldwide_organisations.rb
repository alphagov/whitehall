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
    has_many :edition_worldwide_organisations, foreign_key: :edition_id, dependent: :destroy
    has_many :worldwide_organisations, through: :edition_worldwide_organisations

    add_trait Trait
  end

  def can_be_associated_with_worldwide_organisations?
    true
  end
end
