require 'test_helper'

class PublishingApi::FatalityNoticePresenterTest < ActiveSupport::TestCase
  setup do
    fatality_notice = build(
      :fatality_notice,
      title: "Fatality Notice title",
      summary: "Fatality Notice summary"
    )

    @presented_fatality_notice = PublishingApi::FatalityNoticePresenter.new(fatality_notice)
  end

  test "it delegates the content id" do
    presented_fatality_notice = PublishingApi::FatalityNoticePresenter.new(
      stub(content_id: "c07da942-7e01-4809-adda-cc31df098e5b")
    )

    assert_equal "c07da942-7e01-4809-adda-cc31df098e5b", presented_fatality_notice.content_id
  end

  test "it presents the title" do
    assert_equal "Fatality Notice title", @presented_fatality_notice.content[:title]
  end

  test "it presents the summary as the description" do
    assert_equal "Fatality Notice summary", @presented_fatality_notice.content[:description]
  end
end
