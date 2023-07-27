require "test_helper"

class RaceConditionTest < ActionDispatch::IntegrationTest
  setup do
    stub_any_publishing_api_call
  end

  # Monkeypatch to control response timings
  class Admin::EditionsController
    before_action :delay_request

    def delay_request
      sleep 1 if current_user.name == "Thread 1 user"
    end
  end

  test "Multiple threads should not override each other's whodunnit" do
    user_one = create(:user, name: "Thread 1 user")
    user_two = create(:user, name: "Thread 2 user")

    edition_one, edition_two = create_list(:news_article, 2)

    [
      Thread.new do
        login_as(user_one)
        patch admin_news_article_path(edition_one), params: {
          edition: { body: "Update from thread 1" },
        }
      end,
      Thread.new do
        sleep 1
        login_as(user_two)
        patch admin_news_article_path(edition_two), params: {
          edition: { body: "Update from thread 2" },
        }
      end,
    ].each(&:join)

    assert_equal user_one.name, edition_one.versions.last&.user&.name
    assert_equal user_two.name, edition_two.versions.last&.user&.name
  end
end
