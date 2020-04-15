require "test_helper"

class AuthorNotifierWorkerTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @edition = create(:edition)
  end

  test "calls the AuthorNotifierService" do
    AuthorNotifierService
      .expects(:call)
      .with(@edition, @user)

    AuthorNotifierWorker.new.perform(@edition.id, @user.id)
  end
end
