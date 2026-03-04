require "test_helper"

class AuthorNotifierJobTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @edition = create(:edition)
  end

  test "calls the AuthorNotifierService" do
    AuthorNotifierService
      .expects(:call)
      .with(@edition, @user)

    AuthorNotifierJob.new.perform(@edition.id, @user.id)
  end
end
