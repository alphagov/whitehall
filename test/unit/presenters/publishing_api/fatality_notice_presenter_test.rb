require 'test_helper'

class PublishingApi::FatalityNoticePresenterTest < ActiveSupport::TestCase
  def present(edition)
    PublishingApi::FatalityNoticePresenter.new(edition)
  end

  def build_fatality_notice(arguments)
    build(:fatality_notice, arguments)
  end

  def build_presenter(arguments)
    present(build_fatality_notice(arguments))
  end

  test "it presents the content id" do
    presented_fatality_notice = present(stub(content_id: "c07da942-7e01-4809-adda-cc31df098e5b"))
    assert_equal "c07da942-7e01-4809-adda-cc31df098e5b", presented_fatality_notice.content_id
  end

  test "it presents the title" do
    presented_fatality_notice = build_presenter(title: "Fatality Notice title")
    assert_equal "Fatality Notice title", presented_fatality_notice.content[:title]
  end

  test "it presents the summary as the description" do
    presented_fatality_notice = build_presenter(summary: "Fatality Notice summary")
    assert_equal "Fatality Notice summary", presented_fatality_notice.content[:description]
  end
end
