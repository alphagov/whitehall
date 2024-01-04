class EditionableSocialMediaAccountsIndexPresenter
  include Rails.application.routes.url_helpers

  attr_accessor :edition

  def initialize(edition)
    @edition = edition
  end

  def social_media_accounts
    edition.social_media_accounts.map do |social_media_account|
      {
        title: social_media_account.service_name,
        rows: social_media_account_rows(social_media_account),
      }
    end
  end

private

  def social_media_account_rows(social_media_account)
    [
      {
        key: "Account",
        value: social_media_account.title,
        actions: [
          {
            label: "Edit",
            href: edit_admin_edition_social_media_account_path(edition, social_media_account),
          },
          {
            label: "Delete",
            href: confirm_destroy_admin_edition_social_media_account_path(edition, social_media_account),
            destructive: true,
          },
        ],
      }
    ]
  end
end
