module Edition::WorldwideOffices
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.edition_worldwide_offices.each do |association|
        edition.edition_worldwide_offices.build(association.attributes.except("id"))
      end
    end
  end

  included do
    has_many :edition_worldwide_offices, foreign_key: :edition_id, dependent: :destroy
    has_many :worldwide_offices, through: :edition_worldwide_offices

    add_trait Trait
  end

  def can_be_associated_with_worldwide_offices?
    true
  end
end
