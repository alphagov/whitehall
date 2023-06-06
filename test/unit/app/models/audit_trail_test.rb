require "test_helper"

class AuditTrailTest < ActiveSupport::TestCase
  def setup
    @previous_whodunnit = AuditTrail.whodunnit
    @user = create(:user)
    @user2 = create(:user)
    AuditTrail.whodunnit = @user
  end

  def teardown
    AuditTrail.whodunnit = @previous_whodunnit
    Timecop.return
  end

  test "#acting_as switches to the supplied user for the duration of the block, returning to the original user afterwards" do
    AuditTrail.acting_as(@user2) do
      assert_equal @user2, AuditTrail.whodunnit
    end
    assert_equal @user, AuditTrail.whodunnit
  end

  test "#acting_as will return to the previous whodunnit, even when an exception is thrown" do
    begin
      AuditTrail.acting_as(@user2) { raise "Boom!" }
    rescue StandardError # rubocop:disable Lint/SuppressedException
    end

    assert_equal @user, AuditTrail.whodunnit
  end
end
