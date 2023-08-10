class WorldwideOrganisationRole < ApplicationRecord
  belongs_to :worldwide_organisation
  belongs_to :role

  validates :worldwide_organisation, :role, presence: true

  after_save :republish_worldwide_organisation_to_publishing_api
  after_destroy :republish_worldwide_organisation_to_publishing_api

  def republish_worldwide_organisation_to_publishing_api
    Whitehall::PublishingApi.republish_async(worldwide_organisation)
  end
end
