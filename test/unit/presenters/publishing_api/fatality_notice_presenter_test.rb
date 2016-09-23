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

  test "it presents the schema_name as fatality_notice" do
    assert_equal "fatality_notice", @presented_fatality_notice.content[:schema_name]
  end

  test "it presents the document type as fatality_notice" do
    assert_equal "fatality_notice", @presented_fatality_notice.content[:document_type]
  end

  test "it presents the global process wide locale as the locale of the fatality_notice" do
    I18n.with_locale "de" do
      assert_equal "de", @presented_fatality_notice.content[:locale]
    end
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

class PublishingApi::FatalityNoticePresenterDetailsTest < ActiveSupport::TestCase
  setup do
    @fatality_notice = create(
      :fatality_notice,
      body: "*Test string*"
    )

    @presented_fatality_notice = PublishingApi::FatalityNoticePresenter.new(@fatality_notice)
  end

  test "it presents the Govspeak body as details rendered as HTML" do
    assert_equal(
      "<div class=\"govspeak\"><p><em>Test string</em></p>\n</div>",
      @presented_fatality_notice.content[:details][:body]
    )
  end

  test "it presents first_public_at as nil for draft" do
    assert_nil @presented_fatality_notice.content[:details][:first_published_at]
  end
end

class PublishingApi::PublishedFatalityNoticePresenterDetailsTest < ActiveSupport::TestCase
  setup do
    @expected_time = Time.new(2015, 12, 25)
    @fatality_notice = create(
      :fatality_notice,
      :published,
      body: "*Test string*",
      first_published_at: @expected_time
    )

    @presented_fatality_notice = PublishingApi::FatalityNoticePresenter.new(@fatality_notice)
  end

  test "it presents first_public_at as details, first_public_at" do
    assert_equal @expected_time, @presented_fatality_notice.content[:details][:first_public_at]
  end

  test "it presents change_history" do
    change_history = [
      {
        "public_timestamp" => @expected_time,
        "note" => "change-note"
      }
    ]

    assert_equal change_history, @presented_fatality_notice.content[:details][:change_history]
  end

  test "it presents the lead organisation content_ids as details, emphasised_organisations" do
    assert_equal(
      @fatality_notice.lead_organisations.map(&:content_id),
      @presented_fatality_notice.content[:details][:emphasised_organisations]
    )
  end
end
