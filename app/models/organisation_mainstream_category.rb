# == Schema Information
#
# Table name: organisation_mainstream_categories
#
#  id                     :integer          not null, primary key
#  organisation_id        :integer          not null
#  mainstream_category_id :integer          not null
#  ordering               :integer          default(99), not null
#  created_at             :datetime
#  updated_at             :datetime
#

class OrganisationMainstreamCategory < ActiveRecord::Base
  belongs_to :organisation, inverse_of: :organisation_mainstream_categories
  belongs_to :mainstream_category

  validates :organisation, :mainstream_category, :ordering, presence: true
  validates :organisation_id, uniqueness: { scope: [:mainstream_category_id] }
end
