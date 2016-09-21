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
    assert_equal  "/government/fatalities/fatality-notice-title", @presented_fatality_notice.content[:base_path]
  end
end
