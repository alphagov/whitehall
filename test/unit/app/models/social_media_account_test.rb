require "test_helper"

class SocialMediaAccountTest < ActiveSupport::TestCase
  # These tests use organisations as a candidate, but any object with this module
  # can be used here. Ideally a seperate stub ActiveRecord object would be used.
  test "destroy deletes related social media accounts" do
    test_object = create(:organisation)
    social_media_account = create(:social_media_account, socialable: test_object)
    test_object.reload
    test_object.destroy!
    assert_nil SocialMediaAccount.find_by(id: social_media_account.id)
  end

  test "creating a new social media account republishes the linked socialable if it's an Organisation" do
    test_object = create(:organisation)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    create(:social_media_account, socialable: test_object)
  end

  test "updating an existing social media account republishes the linked socialable if it's an Organisation" do
    test_object = create(:organisation)
    social_media_account = create(:social_media_account, socialable: test_object)
    social_media_account.title = "Test"
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    social_media_account.save!
  end

  test "deleting a social media account republishes the linked socialable if it's an Organisation" do
    test_object = create(:organisation)
    social_media_account = create(:social_media_account, socialable: test_object)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    social_media_account.destroy!
  end

  test "creating a new social media account republishes the linked socialable if it's a WorldwideOrganisation" do
    test_object = create(:worldwide_organisation)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    create(:social_media_account, socialable: test_object)
  end

  test "updating an existing social media account republishes the linked socialable if it's a WorldwideOrganisation" do
    test_object = create(:worldwide_organisation)
    social_media_account = create(:social_media_account, socialable: test_object)
    social_media_account.title = "Test"
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    social_media_account.save!
  end

  test "deleting a social media account republishes the linked socialable if it's a Worldwide Organisation" do
    test_object = create(:worldwide_organisation)
    social_media_account = create(:social_media_account, socialable: test_object)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).once
    social_media_account.destroy!
  end

  test "creating a new social media account does not republish the linked socialable if it's not an Organisation or WorldwideOrganisation" do
    test_object = create(:world_location)
    Whitehall::PublishingApi.expects(:republish_async).with(test_object).never
    create(:social_media_account, socialable: test_object)
  end

  # moved from duplicate file
  test "should be invalid without a url" do
    account = build(:social_media_account, url: nil)
    assert_not account.valid?
    assert_includes account.errors.full_messages, "Url can't be blank"
  end

  test "should be invalid with a malformed url" do
    account = build(:social_media_account, url: "invalid-url", social_media_service: create(:social_media_service))
    assert_not account.valid?
    assert_includes account.errors.full_messages, "Url is not valid. Make sure it starts with http(s)"
  end

  test "should be valid with a url with HTTP protocol" do
    account = create(:social_media_account, url: "http://example.com")
    assert account.valid?
  end

  test "should be valid with a url with HTTPS protocol" do
    account = create(:social_media_account, url: "https://example.com")
    assert account.valid?
  end

  test "should be invalid without a social media service" do
    account = build(:social_media_account, social_media_service_id: nil)
    assert_not account.valid?
    assert_includes account.errors.full_messages, "Social media service can't be blank"
  end

  test "display_name is the title if present" do
    account = build(:social_media_account, title: "My face")
    assert_equal "My face", account.display_name
  end

  test "display_name is the name of the service if the title is blank" do
    sms = build(:social_media_service, name: "Facebark")
    account = build(:social_media_account, title: "", social_media_service: sms)
    assert_equal "Facebark", account.display_name
  end

  test "should accept multiple translations" do
    account = create(:social_media_account)

    I18n.with_locale(:en) do
      account.update(url: "https://example.com", title: "Title in English")
    end
    I18n.with_locale(:cy) do
      account.update(url: "https://example.cy", title: "Title in Welsh")
    end

    I18n.with_locale(:en) do
      assert_equal "https://example.com", account.url
      assert_equal "Title in English", account.title
    end

    I18n.with_locale(:cy) do
      assert_equal "https://example.cy", account.url
      assert_equal "Title in Welsh", account.title
    end
  end
end
