class SocialMediaAccount < ApplicationRecord
  belongs_to :socialable, polymorphic: true
  belongs_to :social_media_service

  after_save :republish_organisation_to_publishing_api
  after_destroy :republish_organisation_to_publishing_api

  validates :social_media_service, presence: true
  validates :url, presence: true, uri: true

  include TranslatableModel
  translates :url, :title

  def republish_organisation_to_publishing_api
    if (socialable_type == "Organisation" || socialable_type == "LegacyWorldwideOrganisation") && socialable.persisted?
      Whitehall::PublishingApi.republish_async(socialable)
    end
  end

  def service_name
    social_media_service.name
  end

  def display_name
    title.presence || service_name
  end
end
