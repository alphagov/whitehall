module Whitehall::Models::SocialMedia
  extend ActiveSupport::Concern

  included do
    has_many :social_media_accounts, as: :socialable, dependent: :destroy
    accepts_nested_attributes_for :social_media_accounts, allow_destroy: true
  end
end
