class SocialMediaAccountTranslation < ApplicationRecord
  belongs_to :social_media_account

  after_save :republish_organisation_to_publishing_api
  after_destroy :republish_organisation_to_publishing_api

  def republish_organisation_to_publishing_api
    if (social_media_account.socialable_type == "Organisation" || social_media_account.socialable_type == "WorldwideOrganisation") && social_media_account.socialable.persisted?
      Whitehall::PublishingApi.republish_async(social_media_account.socialable)
    end
  end
end
