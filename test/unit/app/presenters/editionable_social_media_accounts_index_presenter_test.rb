require "test_helper"

class EditionableSocialMediaAccountsIndexPresenterTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  test "EditionableSocialMediaAccountsIndexPresenter.social_media_accounts should return an array of accounts for the edition" do
    editionable_worldwide_organisation = create(:editionable_worldwide_organisation, translated_into: "cy")
    social_media_account_1 = create(:social_media_account)
    social_media_account_2 = create(:social_media_account)
    editionable_worldwide_organisation.social_media_accounts << [social_media_account_1, social_media_account_2]

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
                href: edit_admin_edition_social_media_account_path(editionable_worldwide_organisation, social_media_account_1, locale: :en),
              },
              {
                label: "Delete",
                href: confirm_destroy_admin_edition_social_media_account_path(editionable_worldwide_organisation, social_media_account_1),
                destructive: true,
              },
            ],
          },
          {
            key: "Welsh Account",
            value: social_media_account_1.title,
            actions: [
              {
                label: "Edit",
                href: edit_admin_edition_social_media_account_path(editionable_worldwide_organisation, social_media_account_1, locale: :cy),
              },
              {
                label: "Delete",
                href: confirm_destroy_admin_edition_social_media_account_path(editionable_worldwide_organisation, social_media_account_1),
                destructive: true,
              },
            ],
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
                href: edit_admin_edition_social_media_account_path(editionable_worldwide_organisation, social_media_account_2, locale: :en),
              },
              {
                label: "Delete",
                href: confirm_destroy_admin_edition_social_media_account_path(editionable_worldwide_organisation, social_media_account_2),
                destructive: true,
              },
            ],
          },
          {
            key: "Welsh Account",
            value: social_media_account_2.title,
            actions: [
              {
                label: "Edit",
                href: edit_admin_edition_social_media_account_path(editionable_worldwide_organisation, social_media_account_2, locale: :cy),
              },
              {
                label: "Delete",
                href: confirm_destroy_admin_edition_social_media_account_path(editionable_worldwide_organisation, social_media_account_2),
                destructive: true,
              },
            ],
          },
        ],
      },
    ]

    assert_equal expected, EditionableSocialMediaAccountsIndexPresenter.new(editionable_worldwide_organisation).social_media_accounts
  end
end
