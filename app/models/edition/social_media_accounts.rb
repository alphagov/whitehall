module Edition::SocialMediaAccounts
  extend ActiveSupport::Concern

  included do
    has_many :social_media_accounts, as: :socialable, dependent: :destroy, autosave: true
  end

  def can_be_associated_with_social_media_accounts?
    true
  end
end
