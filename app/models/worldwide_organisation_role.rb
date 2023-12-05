class WorldwideOrganisationRole < ApplicationRecord
  belongs_to :legacy_worldwide_organisation, foreign_key: :worldwide_organisation_id
  belongs_to :role

  validates :legacy_worldwide_organisation, :role, presence: true

  after_save :republish_worldwide_organisation_to_publishing_api
  after_destroy :republish_worldwide_organisation_to_publishing_api

  def republish_worldwide_organisation_to_publishing_api
    Whitehall::PublishingApi.republish_async(legacy_worldwide_organisation)
  end
end
