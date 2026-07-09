class SocialMediaAccount < ApplicationRecord
  include TranslatableModel

  belongs_to :socialable, polymorphic: true
  belongs_to :social_media_service

  after_save :republish_organisation_to_publishing_api
  after_destroy :republish_organisation_to_publishing_api

  validates :social_media_service, presence: true
  validates :url, presence: true, uri: true

  translates :url, :title

  def republish_organisation_to_publishing_api
    if socialable_type == "Organisation" && socialable.persisted?
      Whitehall::PublishingApi.republish_async(socialable)
    end
  end

  def service_name
    social_media_service.name
  end

  def display_name
    return title if title.present?
    return "Follow us on X" if service_name == "X"

    service_name
  end
end
