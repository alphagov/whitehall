class WorldwideOrganisationRole < ActiveRecord::Base
  belongs_to :worldwide_organisation
  belongs_to :role

  validates :worldwide_organisation, :role, presence: true
end
