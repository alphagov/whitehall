require 'test_helper'

class PublishingApi::FatalityNoticePresenterTest < ActiveSupport::TestCase
  setup do
    @fatality_notice = create(
      :fatality_notice,
      title: "Fatality Notice title",
      summary: "Fatality Notice summary"
    )

    @presented_fatality_notice = PublishingApi::FatalityNoticePresenter.new(@fatality_notice)
  end

  test "it delegates the content id" do
    assert_equal @fatality_notice.content_id, @presented_fatality_notice.content_id
  end

  test "it presents the title" do
    assert_equal "Fatality Notice title", @presented_fatality_notice.content[:title]
  end

  test "it presents the summary as the description" do
    assert_equal "Fatality Notice summary", @presented_fatality_notice.content[:description]
  end

  test "it presents the base_path" do
    assert_equal "/government/fatalities/fatality-notice-title", @presented_fatality_notice.content[:base_path]
  end

  test "it presents updated_at if public_timestamp is nil" do
    assert_equal @fatality_notice.updated_at, @presented_fatality_notice.content[:public_updated_at]
  end

  test "it presents the publishing_app as whitehall" do
    assert_equal 'whitehall', @presented_fatality_notice.content[:publishing_app]
  end

  test "it presents the rendering_app as whitehall-frontend" do
    assert_equal 'whitehall-frontend', @presented_fatality_notice.content[:rendering_app]
  end  
end


class PublishingApi::FatalityNoticePresenterWithPublicTimestampTest < ActiveSupport::TestCase
  setup do
    @expected_time = Time.parse("10/01/2016")
    @fatality_notice = create(
      :fatality_notice
    )
    @fatality_notice.public_timestamp = @expected_time
    @presented_fatality_notice = PublishingApi::FatalityNoticePresenter.new(@fatality_notice)
  end

  test "it presents public_timestamp if it exists" do
    assert_equal @expected_time, @presented_fatality_notice.content[:public_updated_at]
  end
end
