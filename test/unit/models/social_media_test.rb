class SocialMediaTest < ActiveSupport::TestCase
  # This test uses organisations as a candidate, but any object with this module
  # can be used here. Ideally a seperate stub ActiveRecord object would be used.
  test 'destroy deletes related social media accounts' do
    test_object = create(:organisation)
    social_media_account = create(:social_media_account, socialable: test_object)
    test_object.destroy
    assert_nil SocialMediaAccount.find_by(id: social_media_account.id)
  end
end
