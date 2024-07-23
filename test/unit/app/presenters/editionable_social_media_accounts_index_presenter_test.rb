require "test_helper"

class EditionableSocialMediaAccountsIndexPresenterTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  test "EditionableSocialMediaAccountsIndexPresenter.social_media_accounts should return an array of accounts for the edition" do
    worldwide_organisation = create(:worldwide_organisation, translated_into: "cy")
    social_media_account_1 = create(:social_media_account)
    social_media_account_2 = create(:social_media_account)
    worldwide_organisation.social_media_accounts << [social_media_account_1, social_media_account_2]

    expected = [
      {
        title: social_media_account_1.service_name,
        rows: [
          {
            key: "English Account",
            value: social_media_account_1.title,
            actions: [
              {
                label: "Edit",
                href: edit_admin_edition_social_media_account_path(worldwide_organisation, social_media_account_1, locale: :en),
              },
            ],
          },
          {
            key: "Welsh Account",
            value: social_media_account_1.title,
            actions: [
              {
                label: "Edit",
                href: edit_admin_edition_social_media_account_path(worldwide_organisation, social_media_account_1, locale: :cy),
              },
            ],
          },
        ],
        summary_card_actions: [
          {
            label: "Delete",
            href: confirm_destroy_admin_edition_social_media_account_path(worldwide_organisation, social_media_account_1),
            destructive: true,
          },
        ],
      },
      {
        title: social_media_account_2.service_name,
        rows: [
          {
            key: "English Account",
            value: social_media_account_2.title,
            actions: [
              {
                label: "Edit",
                href: edit_admin_edition_social_media_account_path(worldwide_organisation, social_media_account_2, locale: :en),
              },
            ],
          },
          {
            key: "Welsh Account",
            value: social_media_account_2.title,
            actions: [
              {
                label: "Edit",
                href: edit_admin_edition_social_media_account_path(worldwide_organisation, social_media_account_2, locale: :cy),
              },
            ],
          },
        ],
        summary_card_actions: [
          {
            label: "Delete",
            href: confirm_destroy_admin_edition_social_media_account_path(worldwide_organisation, social_media_account_2),
            destructive: true,
          },
        ],
      },
    ]

    assert_equal expected, EditionableSocialMediaAccountsIndexPresenter.new(worldwide_organisation).social_media_accounts
  end
end
