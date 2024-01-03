module Edition::SocialMediaAccounts
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.social_media_accounts.each do |association|
        edition.social_media_accounts.build(association.attributes.except("id", "socialable_id", "socialable_type"))
      end
    end
  end

  included do
    has_many :social_media_accounts, as: :socialable, dependent: :destroy, autosave: true

    add_trait Trait
  end

  def can_be_associated_with_social_media_accounts?
    true
  end
end
