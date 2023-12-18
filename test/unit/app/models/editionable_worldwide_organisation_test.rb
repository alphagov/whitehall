require "test_helper"

class EditionableWorldwideOrganisationTest < ActiveSupport::TestCase
  test "can be associated with one or more social media accounts" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    social_media_account = create(:social_media_account)
    worldwide_organisation.social_media_accounts << social_media_account

    assert_equal [social_media_account], worldwide_organisation.reload.social_media_accounts
  end

  test "destroys associated social media accounts" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    social_media_account = create(:social_media_account)
    worldwide_organisation.social_media_accounts << social_media_account

    worldwide_organisation.destroy!

    assert_equal 0, worldwide_organisation.social_media_accounts.count
  end
end
