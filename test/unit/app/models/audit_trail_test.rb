require "test_helper"

class AuditTrailTest < ActiveSupport::TestCase
  def setup
    @user = create(:user)
    @user2 = create(:user)
  end

  test "#acting_as changes Current.user for the duration of the block, reverting to the original user afterwards" do
    Current.user = @user

    AuditTrail.acting_as(@user2) do
      assert_equal @user2, Current.user
    end

    assert_equal @user, Current.user
  end

  test "#acting_as reverts Current.user, even when an exception is thrown" do
    Current.user = @user

    assert_raises do
      AuditTrail.acting_as(@user2) { raise "Boom!" }
    end

    assert_equal @user, Current.user
  end
end
