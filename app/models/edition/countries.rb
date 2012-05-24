module Edition::Countries
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.countries = @edition.countries
    end
  end

  included do
    has_many :edition_countries, foreign_key: :edition_id, dependent: :destroy
    has_many :countries, through: :edition_countries

    add_trait Trait
  end

  def can_be_associated_with_countries?
    true
  end

  module ClassMethods
    def in_country(country)
      joins(:countries).where('countries.id' => country)
    end
  end
end