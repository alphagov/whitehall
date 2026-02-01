require "test_helper"

class Admin::TopicalEventsSocialMediaControllerTest < ActionController::TestCase
  tests Admin::TopicalEventsController

  setup do
    login_as :writer
    @event = create(:topical_event)
    create(:social_media_service, name: "Twitter", id: "twitter")
    create(:social_media_service, name: "Facebook", id: "facebook")
    create(:social_media_service, name: "YouTube", id: "youtube")
  end

  should_be_an_admin_controller

  test "PUT :update with social media attributes saves to block_content" do
    social_media_params = {
      "0" => {
        "social_media_service_id" => "twitter",
        "url" => "https://twitter.com/govuk",
        "title" => "Government Twitter",
      },
    }

    put :update, params: {
      id: @event,
      topical_event: {
        social_media_accounts_attributes: social_media_params,
      },
    }

    assert_response :redirect

    @event.reload

    links = @event.block_content["social_media_links"]
    assert_equal 1, links.count
    assert_equal "twitter", links.first["social_media_service_id"]
    assert_equal "https://twitter.com/govuk", links.first["url"]

    assert_equal 1, @event.social_media_accounts.count
    assert_equal "Government Twitter", @event.social_media_accounts.first.title
  end

  test "PUT :update with multiple accounts preserves order and data" do
    params = {
      "0" => { "social_media_service_id" => "facebook", "url" => "https://fb.com/1", "title" => "FB" },
      "1" => { "social_media_service_id" => "youtube", "url" => "https://yt.com/1", "title" => "YT" },
    }

    put :update, params: {
      id: @event,
      topical_event: {
        social_media_accounts_attributes: params,
      },
    }

    @event.reload
    assert_equal 2, @event.block_content["social_media_links"].count
    assert_equal "facebook", @event.social_media_accounts[0].social_media_service_id
    assert_equal "youtube", @event.social_media_accounts[1].social_media_service_id
  end

  test "PUT :update with _destroy removes the link" do
    @event.block_content = {
      "social_media_links" => [
        { "social_media_service_id" => "twitter", "url" => "https://twitter.com/old", "title" => "Old" },
      ],
    }
    @event.save!(validate: false)

    params = {
      "0" => {
        "social_media_service_id" => "twitter",
        "url" => "https://twitter.com/old",
        "_destroy" => "1",
      },
    }

    put :update, params: {
      id: @event,
      topical_event: {
        social_media_accounts_attributes: params,
      },
    }

    @event.reload
    assert_empty @event.block_content["social_media_links"] || []
  end
end
