require "test_helper"

class Edition::AuditTrailTest < ActiveSupport::TestCase
  def setup
    @previous_whodunnit = Edition::AuditTrail.whodunnit
    @user = create(:user)
    @user2 = create(:user)
    Edition::AuditTrail.whodunnit = @user
  end

  def teardown
    Edition::AuditTrail.whodunnit = @previous_whodunnit
    Timecop.return
  end

  test "#acting_as switches to the supplied user for the duration of the block, returning to the original user afterwards" do
    Edition::AuditTrail.acting_as(@user2) do
      assert_equal @user2, Edition::AuditTrail.whodunnit
    end
    assert_equal @user, Edition::AuditTrail.whodunnit
  end

  test "#acting_as will return to the previous whodunnit, even when an exception is thrown" do
    begin
      Edition::AuditTrail.acting_as(@user2) { raise "Boom!" }
    rescue StandardError # rubocop:disable Lint/SuppressedException
    end

    assert_equal @user, Edition::AuditTrail.whodunnit
  end
end
