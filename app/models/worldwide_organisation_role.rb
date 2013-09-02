# == Schema Information
#
# Table name: worldwide_organisation_roles
#
#  id                        :integer          not null, primary key
#  worldwide_organisation_id :integer
#  role_id                   :integer
#  created_at                :datetime
#  updated_at                :datetime
#

class WorldwideOrganisationRole < ActiveRecord::Base
  belongs_to :worldwide_organisation
  belongs_to :role

  validates :worldwide_organisation, :role, presence: true
end
