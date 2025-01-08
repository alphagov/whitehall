module Edition::SocialMediaAccounts
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      @edition.social_media_accounts.each do |association|
        new_social_media_account = edition.social_media_accounts.create!(association.attributes.except("id", "socialable_id", "socialable_type"))

        @edition.non_english_translated_locales.map(&:code).each do |locale|
          I18n.with_locale(locale) do
            new_social_media_account.update(association.attributes.except("id", "socialable_id", "socialable_type"))
          end
        end
      end
    end
  end

  included do
    has_many :social_media_accounts, -> { extending(UserOrderableExtension).order(:ordering) }, as: :socialable, dependent: :destroy, autosave: true

    add_trait Trait
  end

  def can_be_associated_with_social_media_accounts?
    true
  end
end
