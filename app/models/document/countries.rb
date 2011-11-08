module Document::Countries
  extend ActiveSupport::Concern

  included do
    has_many :document_countries, foreign_key: :document_id
    has_many :countries, through: :document_countries
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