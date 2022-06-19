require "test_helper"

class EditionAuthBypassUpdaterTest < ActiveSupport::TestCase
  test "#call" do
    edition = create(:draft_edition)
    user = create(:user)
    updater = MiniTest::Mock.new
    service = EditionAuthBypassUpdater.new(
      edition: edition,
      current_user: user,
      updater: updater,
    )

    uid = SecureRandom.uuid
    SecureRandom.stubs(uuid: uid)

    updater.expect :perform!, true

    service.call

    assert_equal edition.auth_bypass_id, uid
    assert_equal edition.edition_authors.last.user, user
  end
end
