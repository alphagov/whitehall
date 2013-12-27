class WorldwideOrganisationRole < ActiveRecord::Base
  belongs_to :worldwide_organisation
  belongs_to :role

  # TODO: figure out why these fail
  # validates :worldwide_organisation, :role, presence: true
end
