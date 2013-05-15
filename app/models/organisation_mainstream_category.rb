class OrganisationMainstreamCategory < ActiveRecord::Base
  belongs_to :organisation, inverse_of: :organisation_mainstream_categories
  belongs_to :mainstream_category

  validates :organisation, :mainstream_category, :ordering, presence: true
  validates :organisation_id, uniqueness: { scope: [:mainstream_category_id] }
end
