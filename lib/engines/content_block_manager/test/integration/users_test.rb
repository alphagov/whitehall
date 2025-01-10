require "test_helper"
require "capybara/rails"

class ContentBlockManager::ContentBlock::UsersTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  setup do
    logout
    @organisation = create(:organisation)
    user = create(:gds_admin, organisation: @organisation)
    login_as(user)
  end

  describe "#show" do
    let(:user_uuid) { SecureRandom.uuid }

    it "returns 404 if the user doesn't exist" do
      ContentBlockManager::SignonUser.expects(:with_uuids).with([user_uuid]).returns([])
      visit content_block_manager_user_path(user_uuid)
      assert_text "Could not find User with ID #{user_uuid}"
    end
  end
end
