class OrganisationMainstreamCategory < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :mainstream_category

  validates :organisation, :mainstream_category, :ordering, presence: true
  validates :organisation_id, uniqueness: { scope: [:mainstream_category_id] }
end
