# == Schema Information
#
# Table name: edition_worldwide_organisations
#
#  id                        :integer          not null, primary key
#  edition_id                :integer
#  worldwide_organisation_id :integer
#  created_at                :datetime
#  updated_at                :datetime
#

class EditionWorldwideOrganisation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :worldwide_organisation

  validates :edition, :worldwide_organisation, presence: true
end
